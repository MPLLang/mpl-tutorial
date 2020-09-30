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
          val (left, right) = ForkJoin.par (fn () => mk i m,  
                                            fn () => mk (i + m + 1) (nn - m)) 
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
    let val (ls, rs) = 
          ForkJoin.par (fn () => toString eToString l, 
                        fn () => toString eToString r) 
    in
      ls ^ " " ^ rs
    end

fun height t =
  case t of 
    Leaf _ => 0
  | Node (l, r) =>
    let 
      val (hl, hr) = ForkJoin.par (fn () => height l, 
                                   fn () => height r) 
    in
      if hl > hr then 1 + hl else 1 + hr
    end 

(* Map f over tree t *)
fun map f t =
  case t of 
    Leaf x => Leaf (f x)
  | Node (l, r) =>
    let 
      val (ll, rr) = ForkJoin.par (fn () => map f l, fn () => map f r) 
    in
      Node (ll, rr)
    end 

(* Reduce tree t with f identity id *)
fun reduce f id t =
  case t of 
    Leaf x => id x
  | Node (l, r) =>
    let val (ls, rs) = ForkJoin.par (fn () => reduce f id l, 
                                     fn () => reduce f id r) in
      f (ls, rs)
    end 

fun filter f t = 
  case t of
    Leaf x => 
      if f x then
        SOME (Leaf x)
      else
        NONE 
  | Node (left, right) =>
      let 
        val (l, r) = ForkJoin.par (fn () => filter f left,
                                   fn () => filter f right)
      in
        case l of  
          NONE => r
        | SOME lt => 
          case r of 
            NONE => l
          | SOME rt => SOME (Node (lt, rt))
      end

datatype 'a stree = SLeaf of 'a | SNode of ('a * 'a stree * 'a stree)
exception Error 
fun iscan id f tree = 
  let 
    fun up t = 
      case t of
        Leaf x => (x, SLeaf x)
      | Node (left, right) => 
        let val ((ls, lst), (rs, rst)) = ForkJoin.par (fn () => up left, 
                                                       fn () => up right)
        in
          (f (ls, rs), SNode (ls, lst, rst))
        end
     
    fun down sum sumtree tree =
      case tree of 
        Leaf x => Leaf (f (sum, x))
      | Node (left, right) => 
      let 
         val SNode(s, l, r) = sumtree 
         val (ls, rs) = ForkJoin.par (fn () => down sum l left, 
                                      fn () => down (sum + s) r right)
      in
        Node (ls, rs)
      end

    val (sum, sumtree) = up tree   
    in 
      down id sumtree tree
    end   

        
end
