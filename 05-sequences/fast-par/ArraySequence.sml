structure ArraySequence = 
struct

structure A = Array
structure AS = ArraySlice

type 'a t = 'a ArraySlice.slice

val GRAIN = 1

val parfor = ForkJoin.parfor GRAIN
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
    String.concatWith "," (List.map f (toList s))

fun subseq s (i, n) = AS.subslice (s, i, SOME n)
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

fun map f s = tabulate (fn i => f (nth s i)) (length s)

fun rev s = tabulate (fn i => nth s (length s - i - 1)) (length s)

fun append (s, t) =
  tabulate (fn i => if i < length s then nth s i else nth t (i - length s))
      (length s + length t)

fun scan f id s = 
  let
    val n = length s
    val _ = print ("scan: len(s) = " ^ Int.toString n ^ "\n")

    fun seqscan s t i = 
      let 
        val prev =         
          if i = 0 then 
            id
          else
            seqscan s t (i-1)

        val () = AS.update (t, i, prev)
      in
        f (prev, nth s i)
      end
  in
    if n <= GRAIN then
      let
        val t = AS.full (alloc n)
        val r = seqscan s t (n-1)
      in
        (t, r)
      end                        
    else
      let 
        val m = Int.div (n, 2)
        val N = m * 2
        val _ = print ("scan: n = " ^ Int.toString n ^ " N = " ^ Int.toString N ^ "\n") 
        val t = tabulate (fn i => f (nth s (2*i), nth s (2*i+1))) m
        val (t, total) = scan f id t

        fun expand i =
          if i < N then
            if Int.mod (i, 2) = 0 then
              nth t (Int.div(i,2))
            else 
            f (nth t (Int.div(i,2)), nth s (i-1))      
          else
            (* assert n = N + 1 *)
            total

        val total = 
          if n > N then
            f(total, nth s (n-1))
          else
            total    
      in
        (tabulate expand n, total) 
      end
  end
end
