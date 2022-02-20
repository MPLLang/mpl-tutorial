structure Tree:
sig

  datatype 'a tree =
    Empty
  | Leaf of 'a
  | Node of int * ('a tree) * ('a tree)

  type 'a t = 'a tree

  (* val makeUnbalanced: (int -> 'a) -> int -> 'a tree *)

  (** sequential versions *)
  val makeBalancedSeq: (int -> 'a) -> int -> 'a tree
  (* val mapSeq: ('a -> 'b) -> 'a tree -> 'b tree *)
  (* val filterSeq: ('a -> bool) -> 'a tree -> 'a tree *)
  (* val reduceSeq: ('a * 'a -> 'a) -> 'a -> 'a tree -> 'a *)

  (** parallel versions *)
  (* val makeBalanced: (int -> 'a) -> int -> 'a tree *)
  (* val map: ('a -> 'b) -> 'a tree -> 'b tree *)
  (* val filter: ('a -> bool) -> 'a tree -> 'a tree *)
  (* val reduce: ('a * 'a -> 'a) -> 'a -> 'a tree -> 'a *)

end =
struct

  datatype 'a tree =
    Empty
  | Leaf of 'a
  | Node of int * ('a tree) * ('a tree)

  type 'a t = 'a tree

  val GRAIN = 1000

  fun makeBalancedSeq f n =
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
      subtree 0 size
    end

end
