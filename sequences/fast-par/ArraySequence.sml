structure ArraySequence = 
struct

structure A = Array
structure AS = ArraySlice

type 'a t = 'a ArraySlice.slice

val GRAIN = 100000

val parfor = ForkJoin.parfor GRAIN
val alloc = ForkJoin.alloc
fun new n = AS.full (alloc n)



fun nth s i = AS.sub (s, i)

fun length s = AS.length s


fun fromList xs = ArraySlice.full (Array.fromList xs)

fun toList s = List.tabulate (length s, nth s)

fun toString f s =
    "<" ^ String.concatWith "," (List.map f (toList s)) ^ ">"

fun empty () = fromList []

(* Return subseq of s[i...i+n-1] *)
fun subseq s (i, n) = 
  AS.subslice (s, i, SOME n)

(* Return subseq of s[i...i+sz] if szopt = SOME sz and until the end of s otherwise *)
fun subslice s (i, szopt) = 
  AS.subslice (s, i, szopt)


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

fun iterate f b s =
  foldl f b s

fun tabulate f n = 
  let 
    val s = ForkJoin.alloc n
    val g = fn i => Array.update (s, i, f i)
    val () = parfor (0, n) g
  in 
    AS.full s
  end  

fun rev s = tabulate (fn i => nth s (length s - i - 1)) (length s)

fun append (s, t) =
  tabulate (fn i => if i < length s then nth s i else nth t (i - length s))
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

    fun seqreduce s =
      AS.foldl (fn (current, acc) => f (acc, current)) id s

  in
    if n <= GRAIN then
      seqreduce s
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
        val t = AS.full (alloc (n+1))
        val r = seqscan s t (n-1)
        val _ = AS.update (t, n, r)
      in
        t
      end                        
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

(* Scan exclusive *)
fun scan f id s = 
  let 
    val t = scanGen f id s
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

fun filter f s = 
  let
    val n = length s

    fun seqfilter s =
      let 
        val taken = AS.foldr (fn (current, acc) => 
                              if f current then current::acc else acc) 
                             [] 
                             s 
       in 
         AS.full (A.fromList taken)
       end
  in
    if n <= GRAIN then
      seqfilter s
    else
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

(* Standard binary search
   Returns NONE if not found and SOME pos if found at position pos *)
fun binarySearch (cmp: 'a * 'a -> order) (a: 'a t) (k: 'a): int option = 
  let 
    fun search (i, j) = 
      let 
        val n = j - i
      in
        if n = 0 then
          NONE
        else if n = 1 then
          case cmp (k, nth a i) of
            LESS => NONE
          | GREATER => NONE
          | EQUAL => SOME i
        else
          let val mid = Int.div (i + j, 2) in
            case cmp (k, nth a mid) of
              LESS => search (i, mid)
            | GREATER => search (mid+1, j)
            | EQUAL => SOME mid
          end
      end
   in
     search (0, length a)
   end          

(* Standard binary search
   Returns the number of  elements of a that are less than k *)
fun binarySplit (cmp: 'a * 'a -> order) (a: 'a t) (k: 'a): int = 
  let 
    fun search (i, j) = 
      let 
        val n = j - i
      in
        if n = 0 then
          0
        else if n = 1 then
          case cmp (k, nth a i) of
            LESS => i
          | GREATER => i+1
          | EQUAL => i+1
        else
          let val mid = Int.div (i + j, 2) in
            case cmp (k, nth a mid) of
              LESS => search (i, mid)
            | GREATER => search (mid+1, j)
            | EQUAL => mid+1
          end
      end
   in
     search (0, length a)
   end          

          
(* Split sorted sequences a and b into 
1) aleft, aright
2) bleft, bright
such that aleft <= bright and bleft <= aright
          and |aleft| + |bleft| = k
Return i and j, where aleft = a[0, ... i] and bleft = b[0, ... j]

*)        
 
fun bivariantSplit a b k =  
  let 
    fun split a b k i j = 
      case (length a, length b) of
        (0, 0) => (i, j)
      | (0, _) => (i, j + k)
      | (_, 0) => (i + k, j)
      | (_, _) =>  
        let
          val na = length a
          val nb = length b
          val midA = Int.div(na, 2) 
          val midB = Int.div(nb, 2) 
        in
          if k <= midA + midB + 1 then
            if nth a midA < nth b midB then
              (* Drop b[midB ..] *)
              split a (subseq b (0, midB)) k i j
            else
              (* Drop a[midA ..] *)
              split (subseq a (0, midA)) b k i j
          else
            if nth a midA < nth b midB then
              (* Drop a[0 .. midA] *)
              split (subseq a (midA + 1, na - midA - 1 )) b (k - midA - 1) (i + midA + 1) j
            else
              (* Drop b[0 .. midB] *)
              split a (subseq b (midB + 1, nb - midB - 1))  (k - midB - 1) i (j + midB + 1)
        end    
  in
    split a b k ~1 ~1
  end

(* Sample search for a k in array a by using comparison function cmp
 *)
fun sampleSearch (degree: int -> int) (cmp: 'a * 'a -> order) (a: 'a t) (k: 'a): int option =
  let 
    val n = length a
    val m = Int.max (degree n, 2)   
    val _ = print ("degree = " ^ Int.toString m ^ "\n")

    (* m-sample array a *)
    fun sample (a, n, m) = 
     let
       val d = Int.div (n, m)
       val _ = print ("Sample: n = " ^ Int.toString n ^ " m = " ^ Int.toString m ^ " d = " ^ Int.toString d ^ "\n")
       val _ = print ("Sample: Last block: " ^ Int.toString ((m-1)*d) ^ " -- " ^ Int.toString (n-1)^ "\n")
       fun fib n = if n < 2 then n else fib(n-1) + fib (n-2)
       val _ = fib 40
     in
       (* First check last block, because it could be short 
          If not found, then look elsewhere
          If found, then good
        *)
       if cmp (k, nth a ((m-1) * d)) <> LESS andalso
          cmp (k, nth a (n-1)) <> GREATER then
            SOME(m*d-d, subslice a (m*d-d, NONE))
       else
         let 
           val res = ref NONE
           val _ = 
             parfor (0, m-1) (fn i =>
               let 
                 val pos = i*d
                 val _ = print ("Sample:  block begin = " ^ Int.toString pos)
                 val _ = print (" end = " ^ Int.toString (pos + d - 1) ^ "\n")
               in
                 if cmp (k, nth a pos) <> LESS andalso
                    cmp (k, nth a (pos +  d - 1)) <> GREATER then
                   res := SOME pos
                 else
                   ()              
               end)
          in
            case !res of 
              NONE => NONE
            | SOME pos => SOME(pos, subslice a (pos, SOME d))
      end
    end
  in 
    if m >= n then 
      case sample (a, n, n) of
        NONE => NONE
      | SOME(start, b) => SOME start
    else
      case sample (a, n, m) of
        NONE => NONE
      | SOME (start, b) => 
          case sampleSearch degree cmp b k of 
            NONE => NONE
          | SOME pos => SOME (start + pos) 
  end

fun mergeSeq a b =	
	let		
		val r = alloc (length a + length b)
    val na = length a
  	val nb = length b

    fun copy x (i, n) k =
			if i = n then
				()
			else
				(Array.update (r, k, nth x i);
				 copy x (i+1, n) (k+1))
			
		fun mergeInplace i j k =
		  if i = na then
				copy b (j, nb) k
			else if j  = nb then
				copy a (i, na) k
  		else
				if nth a i < nth b j then
					 (Array.update (r, k, nth a i);
					 mergeInplace (i+1) j (k+1))
			  else 
					 (Array.update (r, k, nth b j);
					 mergeInplace i (j+1) (k+1))					
	in
		(mergeInplace 0 0 0; AS.full r)
  end								 


end
