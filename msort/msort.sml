(* Usage:
 * msort [-n <input size> [--check] [--seq | --par] 
 *)

structure S = ArraySequence
structure CLA = CommandLineArgs

val par = ForkJoin.par

val usage = "Please supply one of '--seq', '--par'"
val doCheck = CLA.parseFlag "check"
val doSeq = CLA.parseFlag "seq"
val doPar = CLA.parseFlag "par"

val defaultInput = 9
val n = CLA.parseInt "n" defaultInput


fun intSeqToString s =
	let
		val prefix = S.take s (Int.min (10, S.length s))
  in											
    (S.toString Int.toString prefix) ^ "..."
  end
		
fun intSeqCmp (s, t) =
	let
	  fun zip i = (S.nth s i, S.nth t i)
    val zipped = S.tabulate zip (S.length s)
    val eqs = S.map (fn (i, j) => i = j) zipped								 
  in								
    S.reduce (fn (x, y) => x andalso y) true eqs 
	end
	

fun msortSeq (cmp: 'a * 'a -> order) (a: 'a Seq.t): 'a Seq.t = 
  (* Sequential merge sort *)
  let
  in
    (a)
  end 

fun msort (cmp: 'a * 'a -> order) (a: 'a Seq.t): 'a Seq.t = 
  (* Parallel merge sort *)	
  let 
  in
		a
  end


val _ = print ("# Begin: msort n =" ^ Int.toString n ^ "\n")
val s = S.tabulate (fn i => Int.mod (Util.hash i, 9999)) n 
val _ = print ("# Merge sorting\n")
val _ = if n <= defaultInput then
          print ("Input = " ^ intSeqToString s ^ "\n")  
        else 
          ()
val result = 
  if doSeq then
    let 
      val _ = print ("# sorting sequentially\n")
      val result = Benchmark.run "running msort" (fn _ => msortSeq Int.compare s)
      val _ = print ("# sequential sort = " ^ intSeqToString result ^ "\n")
    in
      result
    end
  else if doPar then
    let 
      val _ = print ("# Sorting in parallel\n")
      val result = Benchmark.run "running msort" (fn _ => msort Int.compare s)
      val _ = print ("# parallel msort = " ^ intSeqToString result ^ "\n")
    in
      result
    end
  else 
    Util.die usage

val _ = 
  if doCheck then
    let
      val resultSeq = msortSeq Int.compare s
    in
      if intSeqCmp(result, resultSeq) then
        print ("Correct? YES\n")
      else
        (print ("Correct? NO! Got: " ^ intSeqToString result ^ " expected: " ^ intSeqToString resultSeq ^ "\n");
         print ("Input: " ^ intSeqToString s  ^ "\n"))
    end
  else 
    ()
 
val _ = print ("# End: msort\n")
