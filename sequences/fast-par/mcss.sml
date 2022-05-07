(* Usage: examples -n <sequence length> *)

structure S = ArraySequence
structure CLA = CommandLineArgs

val doCheck = CLA.parseFlag "check"
val doSerial = CLA.parseFlag "seq"
val doParallel = CLA.parseFlag "par"

val defaultInput = 9
val n = CLA.parseInt "n" defaultInput

fun iteratePrefixes f b s =
  let 
    fun g ((l, b), a) = (b::l, f(b, a))
    val (l, r) = S.iterate g ([], b) s
  in 
    (S.fromList (List.rev l), r)
  end

fun iteratePrefixesUnordered f b s =
  let 
    fun g ((l, b), a) = (b::l, f(b, a))
    val (l, r) = S.iterate g ([], b) s
  in 
    (S.fromList l, r)
  end


fun mcssSeq a = 
  (* Kanade's linear-time sequential algorithm *)
  let
    fun f(sum, x) = 
        if sum + x >= x then
          sum + x
        else
          x
    val (b, total) = iteratePrefixesUnordered f 0 a
    val m = S.reduce Int.max (S.nth b 0) b
  in
    Int.max (m, total)
  end 

fun mcss a = 
  let 
    val b = S.scanWithTotal Int.+ 0 a
    (* use first element of the sequence for min identity *)
    val (c, _) = S.scan Int.min (S.nth b 0) b    
    val d = S.tabulate 
              (fn i => (S.nth b (i+1)) - (S.nth c (i+1)))
              (S.length a)
    (*
    val _ = print ("b = " ^ S.toString Int.toString b ^ "\n")
    val _ = print ("c = " ^ S.toString Int.toString c ^ "\n")
    val _ = print ("d = " ^ S.toString Int.toString d ^ "\n")
    *)
   in
     (* use first element of the sequence for max identity *)
     S.reduce Int.max (S.nth d 0) d
   end

val _ = print ("# Begin: MCSS n =" ^ Int.toString n ^ "\n")
val m = Int.max (n div 100, 10)
val s = S.tabulate (fn i => (Util.hash i) mod m - (Util.hash (2*n+i+1))  mod m) n
val _ = print ("# Calculating mcss\n")
val _ = if n <= defaultInput then
          print ("Input = " ^ S.toString Int.toString s ^ "\n")  
        else 
          ()
val _ = 
  if doSerial then
    let 
      val _ = print ("# Calculating sequentially\n")
      val rseq = mcssSeq s
    in
      print ("# sequential mcss = " ^ Int.toString rseq ^ "\n")
    end
  else if doParallel then
    let 
      val _ = print ("# Calculating in parallel\n")
      val rpar = mcss s 
    in
      print ("# parallel mcss = " ^ Int.toString rpar ^ "\n")
    end
  else 
    print ("Please supply one of '--seq' ar '--par' flag\n")
 
val _ = print ("# End: MCSS\n")
