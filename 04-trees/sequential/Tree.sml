structure Tree = 
struct

datatype t = Leaf | Node of t * t
  
(* Define "size of a tree" as the number of internal nodes *)

(* Create a balanced tree of the given size n *)
fun mk_balanced n = 
  if n = 0 then
    Leaf
  else    
    let 
      val nn = n - 1 
      val n2 = Int.div (nn, 2) 
      val left = mk_balanced n2 
      val right = mk_balanced (nn - n2 ) 
    in
      Node (left, right) 
    end

(* Create an un balanced tree of the given size n *)
fun mk_unbalanced n = 
  if n = 0 then
    Leaf
  else    
    let 
      val left = mk_unbalanced (n - 1) 
    in
      Node (left, Leaf) 
    end

fun height t =
  case t of 
    Leaf => 0
  | Node (l, r) =>
    let val (hl, hr) = (height l, height r) in
      if hl > hr then 1 + hl else 1 + hr
    end 
end
