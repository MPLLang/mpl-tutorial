structure ArraySequence = 
struct

structure A = Array
structure AS = ArraySlice

type 'a t = 'a ArraySlice.slice

val GRAIN = 1
val parfor = ForkJoin.parfor 1
val alloc = ForkJoin.alloc


fun length s = AS.length s

fun nth s i = 
  let 
    val n = length s 
(*    val () = print ("nth: i = " ^ Int.toString i ^ " n = " ^ Int.toString n ^ "\n") *)
   in 
     AS.sub (s, i)
   end


fun empty () = AS.full (A.fromList [])
fun fromList xs = ArraySlice.full (Array.fromList xs)
fun toList s = List.tabulate (length s, nth s)

fun toString f s =
    "<" ^ String.concatWith "," (List.map f (toList s)) ^ ">"

(* Return subseq of s[i...i+n-1] *)
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
    val g = fn i => Array.update (s, i, f i)
    val () = parfor (0, n) g
  in 
    AS.full s
  end  

fun apply (f: 'a -> unit) (s: 'a t): unit = 
  parfor (0, length s) (fn i => f (nth s i)) 

fun applyi (f: int * 'a -> unit) (s: 'a t): unit = 
  parfor (0, length s) (fn i => f (i, nth s i)) 

fun map f s = 
  tabulate (fn i => f (nth s i)) (length s)

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

fun rev s = tabulate (fn i => nth s (length s - i - 1)) (length s)

fun append (s, t) =
  tabulate (fn i => if i < length s then nth s i else nth t (i - length s))
      (length s + length t)

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
        val N = m * 2
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

fun scan f id s = 
  let 
    val t = scanGen f id s
    val n = length s 
  in
    (subseq t (0,n), nth t n)
  end 

fun iscan f id s = 
  let 
    val t = scanGen f id s
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
