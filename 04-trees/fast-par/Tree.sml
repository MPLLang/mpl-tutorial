structure Tree = 
struct

(* Define "size of a tree" as the number of internal nodes *)

(* A binary ("apple") tree of type 'a elements ("apples")" 
   Each node holds the size of the subtree rooted at it
 *) 

datatype 'a t = Leaf of 'a | Node of int * 'a t * 'a t

val GRAIN = 5000
  
fun mkBalancedSeq i n = 
  let
    fun mk i n = 
      if n = 0 then
        Leaf i 
      else    
        let 
          val nn = n - 1 
          val m = Int.div (nn, 2) 
          val (left, right) = (mk i m,  
                               mk (i + m + 1) (nn - m)) 
        in
          Node (n, left, right) 
        end
  in
    mk i n
  end


fun heightSeq t = 
  case t of 
    Leaf _ => 0
  | Node (n, l, r) =>
    let 
      val (hl, hr) = (heightSeq l, 
                      heightSeq r) 
    in
      if hl > hr then 1 + hl else 1 + hr
    end 

fun mapSeq f t =
  case t of 
    Leaf x => Leaf (f x)
  | Node (n, l, r) =>
      let 
        val (ll, rr) = (mapSeq f l, 
                        mapSeq f r) 
      in
        Node (n, ll, rr)
      end 

(* Reduce tree t with f identity id *)
fun reduceSeq f id t =
  case t of 
    Leaf x => f (id, x)
  | Node (_, l, r) =>
    let val (ls, rs) = (reduceSeq f id l, reduceSeq f id r) in
      f (ls, rs)
    end 

fun filterSeq f t = 
  case t of 
    Leaf x => 
      if f x then
         SOME (Leaf x)
      else
         NONE
  | Node (n, l, r) =>
      let
        val (l, r) = (filterSeq f l, filterSeq f r)
      in
        case l of 
          NONE => r
        | SOME (ll as Leaf x) =>
            (case r of 
               NONE => l
             | SOME (rr as Leaf y) => SOME (Node (1, ll, rr))
             | SOME (rr as Node(nrr, lrr, rrr)) => SOME (Node (nrr, ll, rr)))
        | SOME (ll as Node (nll, lll, rll)) =>
            (case r of
               NONE => l
             | SOME (rr as Leaf y) => SOME (Node (nll, ll, rr))
             | SOME (rr as Node(nrr, lrr, rrr)) => SOME (Node (nrr+nll+1, ll, rr)))
      end

(* Create a balanced integer tree of the given size n *)
fun mkBalanced n = 
  let
    fun mk i n = 
      if n <= GRAIN then
        mkBalancedSeq i n
      else    
        let 
          val nn = n - 1 
          val m = Int.div (nn, 2) 
          val (left, right) = ForkJoin.par (fn () => mk i m,  
                                            fn () => mk (i + m + 1) (nn - m)) 
        in
          Node (n, left, right) 
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
          Node (n, left, Leaf n) 
        end
  in
    mk 0 n
  end

(* Take eToString which makes a string out of an element return a string rep of the tree. *)
fun toString eToString t = 
  case t of 
    Leaf x => eToString x
  | Node (_, l, r) => 
    let val (ls, rs) = 
          ForkJoin.par (fn () => toString eToString l, 
                        fn () => toString eToString r) 
    in
      ls ^ " " ^ rs
    end
  

fun height t =
  case t of 
    Leaf _ => 0
  | Node (n, l, r) =>
    if n < GRAIN then
      heightSeq t
    else
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
  | Node (n, l, r) =>
    if n < GRAIN then
      mapSeq f t
    else
      let 
        val (ll, rr) = ForkJoin.par (fn () => map f l, fn () => map f r) 
      in
        Node (n, ll, rr)
      end 

(* Reduce tree t with f identity id *)
fun reduce f id t =
  case t of 
    Leaf x => f (id, x)
  | Node (n, l, r) =>
    if n <= GRAIN then
      reduceSeq f id t
    else
      let 
        val (ls, rs) = ForkJoin.par (fn () => reduceSeq f id l, 
                                     fn () => reduceSeq f id r) 
      in
        f (ls, rs)
      end 

fun filter f t = 
  case t of 
    Leaf x => 
      if f x then
         SOME (Leaf x)
      else
         NONE
  | Node (n, l, r) =>
      if n <= GRAIN then
        filterSeq f t
      else 
        let
          val (l, r) = ForkJoin.par (fn () => filter f l, 
                                     fn () => filter f r)
        in
          case l of 
            NONE => r
          | SOME (ll as Leaf x) =>
              (case r of 
                 NONE => l
               | SOME (rr as Leaf y) => SOME (Node (1, ll, rr))
               | SOME (rr as Node(nrr, lrr, rrr)) => SOME (Node (nrr, ll, rr)))
          | SOME (ll as Node (nll, lll, rll)) =>
              (case r of
                 NONE => l
               | SOME (rr as Leaf y) => SOME (Node (nll, ll, rr))
               | SOME (rr as Node(nrr, lrr, rrr)) => SOME (Node (nrr+nll+1, ll, rr)))
        end

datatype 'a stree = SLeaf of 'a | SNode of ('a * 'a stree * 'a stree)
 
fun scan id f tree = 
  let 
    fun upSeq tree = 
      case tree of 
        Leaf x => (x, SLeaf x)
      | Node (n, l, r) =>
          let val ((sl, slt), (sr, srt)) = (upSeq l, upSeq r)
          in (f (sl, sr), SNode (sl, slt, srt)) end

    fun downSeq sum tree ut = 
      case tree of 
        Leaf x => Leaf sum
      | Node (n, l, r) =>    
          let val SNode (s, ul, ur) = ut 
              val (ll, rr) = (downSeq sum l ul, downSeq (f(sum, s)) r ur)    
          in Node (n, ll, rr) end

    fun up tree = 
      case tree of 
        Leaf x => (x, SLeaf x)
      | Node (n, l, r) =>
          if n <= GRAIN then
            upSeq tree
          else
            let val ((sl, slt), (sr, srt)) = ForkJoin.par (fn () => up l,
                                                           fn () => up r)
            in (f (sl, sr), SNode (sl, slt, srt)) end

    fun down sum tree ut = 
      case tree of 
        Leaf x => Leaf sum
      | Node (n, l, r) =>    
          if n<= GRAIN then
             downSeq sum tree ut
          else 
            let val SNode (s, ul, ur) = ut 
                val (ll, rr) = ForkJoin.par (fn () => down sum l ul,
                                             fn () => down (f(sum, s)) r ur)
            in Node (n, ll, rr) end
            
    val (sum, stree) = up tree
  in
    (down id tree stree, sum)
  end    


(* Inclusive scan *)
fun iscan id f tree = 
  let 
    fun upSeq tree = 
      case tree of 
        Leaf x => (x, SLeaf x)
      | Node (n, l, r) =>
          let val ((sl, slt), (sr, srt)) = (upSeq l, upSeq r)
          in (f (sl, sr), SNode (sl, slt, srt)) end

    fun downSeq sum tree ut = 
      case tree of 
        Leaf x => Leaf (f(sum, x))
      | Node (n, l, r) =>    
          let val SNode (s, ul, ur) = ut 
              val (ll, rr) = (downSeq sum l ul, downSeq (f(sum, s)) r ur)    
          in Node (n, ll, rr) end

    fun up tree = 
      case tree of 
        Leaf x => (x, SLeaf x)
      | Node (n, l, r) =>
          if n <= GRAIN then
            upSeq tree
          else
            let val ((sl, slt), (sr, srt)) = ForkJoin.par (fn () => up l,
                                                           fn () => up r)
            in (f (sl, sr), SNode (sl, slt, srt)) end

    fun down sum tree ut = 
      case tree of 
        Leaf x => Leaf (f(sum, x))
      | Node (n, l, r) =>    
          if n<= GRAIN then
             downSeq sum tree ut
          else 
            let val SNode (s, ul, ur) = ut 
                val (ll, rr) = ForkJoin.par (fn () => down sum l ul,
                                             fn () => down (f(sum, s)) r ur)
            in Node (n, ll, rr) end
            
    val (sum, stree) = up tree
  in
    down id tree stree
  end    

end

