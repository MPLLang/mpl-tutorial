structure Tree = 
struct

(* A binary ("apple") tree of type 'a elements ("apples")" *) 
datatype 'a t = Leaf of 'a | Node of 'a t * 'a t
  
(* Define "size of a tree" as the number of internal nodes *)

(* Create a balanced integer tree of the given size n *)
fun mkBalanced n = 
  let
    fun mk i n = 
      if n = 0 then
        Leaf i 
      else    
        let 
          val nn = n - 1 
          val m = Int.div (nn, 2) 
          val left = mk i m
          val right = mk (i + m + 1) (nn - m) 
        in
          Node (left, right) 
        end
  in
    mk 0 n
  end

(* Create an un balanced tree of the given size n *)
fun mkUnbalanced n = 
  let
    fun mk i n = 
      if n = 0 then
        Leaf i
      else    
        let 
          val left = mk i (n - 1) 
        in
          Node (left, Leaf n) 
        end
  in
    mk 0 n
  end

(* Take eToString which makes a string out of an element return a string rep of the tree. *)
fun toString eToString t = 
  case t of 
    Leaf x => eToString x
  | Node (l, r) => 
    let val ls = toString eToString l 
        val rs = toString eToString r 
    in
      ls ^ " " ^ rs
    end

fun height t =
  case t of 
    Leaf _ => 0
  | Node (l, r) =>
    let val (hl, hr) = (height l, height r) in
      if hl > hr then 1 + hl else 1 + hr
    end 

(* Map f over tree t *)
fun map f t =
  case t of 
    Leaf x => Leaf (f x)
  | Node (l, r) =>
    let val (ll, rr) = (map f l, map f r) in
      Node (ll, rr)
    end 

(* Reduce tree t with f identity id *)
fun reduce f id t =
  case t of 
    Leaf x => f (id, x)
  | Node (l, r) =>
    let val (ls, rs) = (reduce f id l, reduce f id r) in
      f (ls, rs)
    end 

end
