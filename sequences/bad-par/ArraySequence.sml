structure ArraySequence = 
struct

structure A = Array
structure AS = ArraySlice

type 'a t = 'a ArraySlice.slice

datatype 'a tree = Leaf of int | Node of ('a tree * 'a tree * 'a)

val parfor = ForkJoin.parfor 1
val alloc = ForkJoin.alloc

fun nth s i = AS.sub (s, i)

fun length s = AS.length s

fun fromList xs = AS.full (A.fromList xs)

fun toList s = List.tabulate (length s, nth s)

fun toString f s =
    "<" ^ String.concatWith "," (List.map f (toList s)) ^ ">"

  (* let  *)
  (*   val n = length s  *)
  (*   val () = print ("nth: i = " ^ Int.toString i ^ " n = " ^ Int.toString n ^ "\n")  *)
  (*  in       *)
  (*  end *)


fun empty () = fromList []

(* Return subseq s[i...i+n-1] *)
fun subseq s (i, n) = 
  AS.subslice (s, i, SOME n)

fun take s k = subseq s (0, k)

fun drop s k = subseq s (k, length s - k)

fun foldl f b s =
  let 
    val n = length s
    fun fold current i = 
      if i = n then
        current
      else
        fold (f(current, nth s i)) (i+1)
   in
     fold b 0
   end

fun tabulate f n = 
  let 
    val s = ForkJoin.alloc n
    val () = parfor (0, n) (fn i => Array.update (s, i, f i))
  in 
    AS.full s
  end  

fun rev s = 
  tabulate (fn i => nth s (length s - i - 1)) (length s)

fun append (s, t) =
  tabulate 
    (fn i => if i < length s then nth s i else nth t (i - length s))
    (length s + length t)

fun map f s = 
  tabulate (fn i => f (nth s i)) (length s)

fun apply (f: 'a -> unit) (s: 'a t): unit = 
  parfor (0, length s) (fn i => f (nth s i)) 

fun applyi (f: int * 'a -> unit) (s: 'a t): unit = 
  parfor (0, length s) (fn i => f (i, nth s i)) 

fun update s (i, v) =
  let
    val result = map (fn x => x) s
    val _ = AS.update (result, i, v)
  in
    result
  end

fun inject s updates =
  let
    val result = map (fn x => x) s
    fun injectOne (i, v) = AS.update (result, i, v)
    val () = apply injectOne updates
  in
    result
  end

fun reduce f id s = 
  let
    val n = length s
  in
    if n = 0 then
      id
    else if n = 1 then
      f (id, nth s 0)
    else
      let
        val m = Int.div (n, 2)
        val (left, right) = (subseq s (0, m), subseq s (m, n-m))
        val (sl, sr) = ForkJoin.par (fn () => reduce f id left, 
                                     fn () => reduce f id right)
      in 
        f (sl, sr)
      end
   end


(* Compute `reduce` for all prefixes of the input sequence,
 * including the empty and the full prefix. 
 *)
fun scanGen f id s = 
  let
    val n = length s
(*    val _ = print ("scan: len(s) = " ^ Int.toString n ^ "\n") *)
  in 
    if n = 0 then
      tabulate (fn i => 0) 1
    else 
      let         
        val m = Int.div (n, 2)
        val t = tabulate (fn i => f (nth s (2*i), nth s (2*i+1))) m
        val t = scanGen f id t

        fun expand i =
          if Int.mod (i, 2) = 0 then
            nth t (Int.div(i,2))
          else 
            f (nth t (Int.div(i,2)), nth s (i-1))      
        in
          tabulate expand (n+1)
        end
   end



(* Compute `reduce` for all prefixes of the input sequence,
 * including the empty and the full prefix. 
 *)
fun scanGenTree f id s = 
  let
    val n = length s
    val res = ForkJoin.alloc (n+1)
		
(*    val _ = print ("scan: len(s) = " ^ Int.toString n ^ "\n") *)
      val ss = toString Int.toString s
      val _ = print ("scan: s = " ^ ss ^ "\n")
			
    fun mkTreeSlice(l: int, r: int) =
     if r = l + 1 then
		   (Leaf l, nth s l)
		 else
		   let 
         val mid = Int.div(l + r, 2)
         val (left, leftsum) = mkTreeSlice(l, mid)
				 val (right, rightsum) = mkTreeSlice(mid, r)
			in
			  (Node(left, right, leftsum), f(leftsum, rightsum))
      end 

    fun scanTree(tree, sum) =
  	  case tree of
        Leaf(l) => Array.update(res, l, sum)
      | Node(l, r, leftSum) =>
    	  let
          val _ = scanTree(l, sum)
          val _ = scanTree(r, f(leftSum, sum))
        in
          ()
        end	
  in 
    if n = 0 then
      (Array.update(res, 0, id); AS.full res)
    else 
      let
			  val (tree, sum) =  mkTreeSlice(0, n)
  			val _ = scanTree(tree, id)								
        val _ = Array.update(res, n, sum)
      in
     	  AS.full res
      end
   end

(* Scan exclusive *)
fun scan f id s = 
  let 
    val t = scanGen f id s
    val n = length s 
  in
    (subseq t (0,n), nth t n)
  end 

fun scanTree f id s = 
  let 
    val t = scanGenTree f id s
    val n = length s 
  in
    (subseq t (0,n), nth t n)
  end 

(* Scan inclusive *)
fun iscan f id s = 
  let 
    val t = scanGen f id s
    val n = length s 
  in
    subseq t (1,n)
  end

fun iscanTree f id s = 
  let 
    val t = scanGenTree f id s
    val n = length s 
  in
    subseq t (1,n)
  end

fun filter f s = 
  let
    val indicators = map (fn x => if f x then 1 else 0) s
    val (offsets, m) = scan (fn (x,y) => x + y) 0 indicators
    val t = alloc m 

    fun copy t (x, i) = 
      if nth indicators i = 1 then
        A.update (t, nth offsets i, x)
      else
        ()

     val () = applyi (copy t) s
   in 
     AS.full t
   end

fun flatten s = 
  let
    val lengths = map length s 
    val (offsets, n) = scan (fn (x,y) => x + y) 0 lengths 
    val t = alloc n
    val _ = 
      parfor (0, length s) (fn i =>
        let 
           val (x, offset) = (nth s i, nth offsets i)
        in
          parfor (0, length x) (fn j =>
            A.update (t, offset + j, nth x j))
        end)
  in 
    AS.full t
  end

end
