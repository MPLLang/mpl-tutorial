structure Tree:
sig

  datatype 'a tree =
    Empty
  | Leaf of 'a
  | Node of int * ('a tree) * ('a tree)

  type 'a t = 'a tree

  val size: 'a tree -> int
  val toString: ('a -> string) -> 'a tree -> string

  val makeUnbalanced: (int -> 'a) -> int -> int -> 'a tree
  val makeBalanced: (int -> 'a) -> int -> int -> 'a tree

  (** sequential versions *)

  val heightSeq: 'a tree -> int
  (* val mapSeq: ('a -> 'b) -> 'a tree -> 'b tree *)
  (* val filterSeq: ('a -> bool) -> 'a tree -> 'a tree *)
  val reduceSeq: ('a * 'a -> 'a) -> 'a -> 'a tree -> 'a
  val scanSeq: ('a * 'a -> 'a) -> 'a -> 'a tree -> 'a tree * 'a

  (** parallel versions *)

  val height: 'a tree -> int
  (* val map: ('a -> 'b) -> 'a tree -> 'b tree *)
  (* val filter: ('a -> bool) -> 'a tree -> 'a tree *)
  val reduce: ('a * 'a -> 'a) -> 'a -> 'a tree -> 'a
  val scan: ('a * 'a -> 'a) -> 'a -> 'a tree -> 'a tree * 'a

end =
struct

  datatype 'a tree =
    Empty
  | Leaf of 'a
  | Node of int * ('a tree) * ('a tree)

  type 'a t = 'a tree

  val GRAIN = 5000


  fun size t =
    case t of
      Empty => 0
    | Leaf _ => 1
    | Node (n, _, _) => n


  fun heightSeq t =
    case t of
      Empty => 0
    | Leaf _ => 1
    | Node (_, l, r) => 1 + Int.max (heightSeq l, heightSeq r)


  fun height t =
    if size t < GRAIN then
      heightSeq t
    else
      case t of
        Empty => 0
      | Leaf _ => 1
      | Node (n, l, r) =>
          1 + Int.max (ForkJoin.par (fn _ => height l, fn _ => height r))


  fun reduceSeq f id t =
    case t of
      Empty => id
    | Leaf x => x
    | Node (_, left, right) => f (reduceSeq f id left, reduceSeq f id right)


  fun reduce f id t =
    if size t < GRAIN then
      reduceSeq f id t
    else
      case t of
        Empty => id
      | Leaf x => x
      | Node (_, left, right) =>
          let
            val (resultLeft, resultRight) =
              ForkJoin.par (fn () => reduce f id left,
                            fn () => reduce f id right)
          in
            f (resultLeft, resultRight)
          end


  fun makeUnbalanced f i n =
    case n of
      0 => Empty
    | 1 => Leaf (f i)
    | _ =>
        let
          val l = Leaf (f i)
          val r = makeUnbalanced f (i+1) (n-1)
        in
          Node (n, l, r)
        end


  fun makeBalanced f i n =
    case n of
      0 => Empty
    | 1 => Leaf (f i)
    | _ =>
        let
          val half = n div 2
          val l = makeBalanced f i half
          val r = makeBalanced f (i + half) (n - half)
        in
          Node (n, l, r)
        end


  fun tabulate f n =
    let
      (** recursive helper computes the subtree with leaf elements
        * f(offset), f(offset+1), ..., f(offset+size-1)
        *)
      fun subtree offset size =
        case size of
          0 => Empty
        | 1 => Leaf (f offset)
        | _ =>
            let
              (** divide approximately in half, such that
                * size = leftSize + rightSize *)
              val leftSize = size div 2
              val rightSize = size - leftSize

              fun left () = subtree offset leftSize
              fun right () = subtree (offset+leftSize) rightSize

              val (l, r) =
                (* granularity control *)
                if size < GRAIN then
                  (left (), right ())
                else
                  ForkJoin.par (left, right)
            in
              Node (size, l, r)
            end
    in
      subtree 0 n
    end


  fun toString f t =
    let
      fun loop t =
        case t of
          Empty => ""
        | Leaf x => f x
        | Node (_, l, r) => loop l ^ "," ^ loop r
    in
      "[" ^ loop t ^ "]"
    end

  (** =========================================================================
    * scan
    *)

  fun scanLoop f acc t =
    case t of
      Empty => (Empty, acc)
    | Leaf x => (Leaf acc, f (acc, x))
    | Node (n, left, right) =>
        let
          val (leftPrefixSums, accLeft) = scanLoop f acc left
          val (rightPrefixSums, accRight) = scanLoop f accLeft right
          val allSums = Node (n, leftPrefixSums, rightPrefixSums)
        in
          (allSums, accRight)
        end


  fun scanSeq f id t =
    scanLoop f id t


  fun scan (f: 'a * 'a -> 'a) (id: 'a) (t: 'a tree) =
    let
      (** "sum tree" is produced by the first phase of the algorithm,
        * the "upsweep", which is essentially the same as a reduce except that
        * it produces a tree which stores all intermediate results.
        *)
      datatype 'a sum_tree =
        GrainSum of 'a
      | NodeSum of 'a * 'a sum_tree * 'a sum_tree

      fun sumOf (st: 'a sum_tree) : 'a =
        case st of
          GrainSum x => x
        | NodeSum (x, _, _) => x

      fun upsweep (t: 'a tree): 'a sum_tree =
        if size t <= GRAIN then
          GrainSum (reduceSeq f id t)
        else
          case t of
            Node (_, left, right) =>
              let
                val (leftSums, rightSums) =
                  ForkJoin.par (fn _ => upsweep left, fn _ => upsweep right)
                val thisSum = f (sumOf leftSums, sumOf rightSums)
              in
                NodeSum (thisSum, leftSums, rightSums)
              end

          | _ => raise Fail "Tree.scan.upsweep: impossible"


      fun downsweep acc (t: 'a tree) (st: 'a sum_tree): ('a tree * 'a) =
        if size t <= GRAIN then
          scanLoop f acc t
        else
          case (t, st) of
            (Node (n, left, right), NodeSum (_, stLeft, stRight)) =>
              let
                val accLeft = f (acc, sumOf stLeft)

                val ((l, _), (r, accTotal)) =
                  ForkJoin.par (fn _ => downsweep acc left stLeft,
                                fn _ => downsweep accLeft right stRight)
              in
                (Node (n, l, r), accTotal)
              end

          | _ => raise Fail "Tree.scan.downsweep: impossible"
    in
      downsweep id t (upsweep t)
    end

end
