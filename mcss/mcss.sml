(* Usage:
 * mcss [-n <input size> [--check] [--seq | --par | --parcas] 
 * Example: mcss [-n <input size> [--check] [--seq | --par | --parcas] 
 *)

structure S = ArraySequence
structure CLA = CommandLineArgs

val par = ForkJoin.par

val usage = "Please supply one of '--seq', '--par' or '--pardc' flag\n"
val doCheck = CLA.parseFlag "check"
val doSeq = CLA.parseFlag "seq"
val doPar = CLA.parseFlag "par"
val doParDC = CLA.parseFlag "pardc"

val defaultInput = 9
val n = CLA.parseInt "n" defaultInput

structure I = IntInf

fun mcssSeq a = 
  (* Kanade's linear-time sequential algorithm *)
  let
    fun f((sum, max), x) = 
      let
        val sumx = I.+(sum, x)
        val sum' =  if I.>= (sumx, x) then sumx else x
        val max' = I.max(max, sum')
      in
        (sum', max')
      end

    val (b, (_, max)) = S.iteratePrefixes f (I.fromInt 0, S.first a) a
  in
    max
  end 

fun mcss a = 
  let 
    val b = S.scanWithTotal I.+ 0 a
    (* use first element of the sequence for min identity *)
    val (c, _) = S.scan I.min (S.nth b 0) b    
    val d = S.tabulate 
              (fn i => (S.nth b (i+1)) - (S.nth c (i+1)))
              (S.length a)
   in
     (* use first element of the sequence for max identity *)
     S.reduce I.max (S.nth d 0) d
   end

fun mcssdc a = 
  let
    val GRAIN = 10000
    fun parameters a =
      let 
        val b = S.scanWithTotal I.+ 0 a
        val total = S.last b
        val maxprefix = S.reduce I.max (S.first b) b
        val c = S.tabulate (fn i => total - (S.nth b i)) (S.length b)
        val maxsuffix = S.reduce I.max (S.first c) c
      in
        (maxprefix, maxsuffix, total)
      end        

    fun mcss a = 
      if S.length a <= GRAIN then
        let 
          val (maxprefix, maxsuffix, total) = parameters a
          val m = mcssSeq a
        in
          (m, maxprefix, maxsuffix, total)
        end
      else 
        let
          val nl = (S.length a) div 2
          val (left, right) = par (fn () => mcss (S.subseqOpt a (0, SOME nl)), 
                                   fn () => mcss (S.subseqOpt a (nl, NONE)))
          val (ml, pl, sl, tl) = left
          val (mr, pr, sr, tr) = right
        in
          (I.max (sl + pr, I.max(ml, mr)),
           I.max (pl, tl + pr),
           I.max (sl + tr, sr),
           I.+(tl, tr))
        end
    val (m, _, _, _) = mcss a
  in
    m
  end

val _ = print ("# Begin: MCSS n =" ^ Int.toString n ^ "\n")
val m = I.fromInt (Int.max (n div 10, 10))
val s = S.tabulate (fn i => I.mod(I.fromInt(Util.hash i), m) - 
                            I.mod(I.fromInt(Util.hash (2*i+1)), m)) n
val _ = print ("# Calculating mcss\n")
val _ = if n <= defaultInput then
          print ("Input = " ^ S.toString I.toString s ^ "\n")  
        else 
          ()
val result = 
  if doSeq then
    let 
      val _ = print ("# Calculating sequentially\n")
      val result = Benchmark.run "running mcss" (fn _ => mcssSeq s)
      val _ = print ("# sequential mcss = " ^ I.toString result ^ "\n")
    in
      result
    end
  else if doPar then
    let 
      val _ = print ("# Calculating in parallel\n")
      val result = Benchmark.run "running mcss" (fn _ => mcss s)
      val _ = print ("# parallel mcss = " ^ I.toString result ^ "\n")
    in
      result
    end
  else if doParDC then
    let 
      val _ = print ("# Calculating in parallel using DC\n")
      val result = Benchmark.run "running mcss" (fn _ => mcssdc s)
      val _ = print ("# parallel mcss = " ^ I.toString result ^ "\n")
    in
      result
    end
  else 
    Util.die usage

val _ = 
  if doCheck then
    let
      val resultSeq = mcssSeq s
    in
      if result = resultSeq then
        print ("Correct? YES\n")
      else
        print ("Correct? NO! Got: " ^ I.toString result ^ " expected: " ^ I.toString resultSeq ^ "\n")
    end
  else 
    ()
 
val _ = print ("# End: MCSS\n")
