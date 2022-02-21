structure Tree:
sig

  datatype 'a tree =
    Empty
  | Leaf of 'a
  | Node of int * ('a tree) * ('a tree)

  type 'a t = 'a tree

  val makeUnbalanced: (int -> 'a) -> int -> int -> 'a tree
  val makeBalanced: (int -> 'a) -> int -> int -> 'a tree

  (** sequential versions *)
  (* val mapSeq: ('a -> 'b) -> 'a tree -> 'b tree *)
  (* val filterSeq: ('a -> bool) -> 'a tree -> 'a tree *)
  val reduceSeq: ('a * 'a -> 'a) -> 'a -> 'a tree -> 'a

  (** parallel versions *)
  (* val map: ('a -> 'b) -> 'a tree -> 'b tree *)
  (* val filter: ('a -> bool) -> 'a tree -> 'a tree *)
  val reduce: ('a * 'a -> 'a) -> 'a -> 'a tree -> 'a

end =
struct

  datatype 'a tree =
    Empty
  | Leaf of 'a
  | Node of int * ('a tree) * ('a tree)

  type 'a t = 'a tree


  fun size t =
    case t of
      Empty => 0
    | Leaf _ => 1
    | Node (n, _, _) => n


  fun reduceSeq f id t =
    case t of
      Empty => id
    | Leaf x => x
    | Node (_, left, right) => f (reduceSeq f id left, reduceSeq f id right)


  val GRAIN = 1000

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

end
