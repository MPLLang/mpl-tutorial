structure Tree = 
struct

datatype t = Leaf | Node of int * t * t

val GRAIN = 1000

fun mk_balanced_seq n = 
  if n <= 2 then
    Leaf
  else    
    let 
      val nn = n - 1 
      val n2 = Int.div (nn, 2) 
      val left = mk_balanced_seq n2 
      val right = mk_balanced_seq (nn - n2 ) 
    in
      Node (n, left, right) 
    end


fun height_seq t =
  case t of 
    Leaf => 0
  | Node (_, l, r) =>
    let val (hl, hr) = (height_seq l, height_seq r) in
      if hl > hr then 1 + hl else 1 + hr
    end 

fun mk_balanced n = 
  if n <= GRAIN then
    mk_balanced_seq n
  else    
    let 
      val nn = n - 1 
      val n2 = Int.div (nn, 2) 
      val (left, right) = ForkJoin.par(fn () => mk_balanced n2, fn () => mk_balanced (nn - n2)) 
    in
      Node (n, left, right) 
    end


fun height t =  
  case t of 
    Leaf => 0
  | Node (n, l, r) =>
    if n < GRAIN then
      height_seq t
    else
      let val (hl, hr) = ForkJoin.par (fn () => height l, fn ()  => height r) in
        if hl > hr then 1 + hl else 1 + hr
      end 
end
