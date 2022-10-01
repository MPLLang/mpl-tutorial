(* Usage: examples -n <sequence length> *)

structure S = ArraySequence
structure CLA = CommandLineArgs

val defaultInput = 9
val n = CLA.parseInt "n" defaultInput

fun fib n = 
  if n < 2 then 
    n 
  else
    fib (n-1) + fib (n-2)

fun testBinarySearch () = 
  let 
    val a = S.tabulate (fn i => 2*i) n
    val sa = S.toString Int.toString a
    val _ = print ("a = " ^ sa ^ "\n")

    (* Failing search *)
    val key = (2*Int.div(n,2) - 1)
    val _ = print ("Looking for: " ^ Int.toString key ^ "\n")
    val result = S.binarySearch Int.compare a key
    val _ =  
      case result of 
        NONE => print ("not found\n")
      | SOME pos => print ("found at position: " ^ Int.toString pos ^ "\n")

    (* Successful search *)
    val key = (2*Int.div(n,2))
    val _ = print ("Looking for: " ^ Int.toString key ^ "\n")
    val result = S.binarySearch Int.compare a key
    val _ =  
      case result of 
        NONE => print ("not found\n")
      | SOME pos => print ("found at position: " ^ Int.toString pos ^ "\n")
  in
    ()
  end

fun testBinarySplit () = 
  let 
    val a = S.tabulate (fn i => 2*i) n
    val sa = S.toString Int.toString a
    val _ = print ("a = " ^ sa ^ "\n")

    (* Failing search *)
    val key = (2*Int.div(n,2) - 1)
    val _ = print ("Looking for: " ^ Int.toString key ^ "\n")
    val result = S.binarySplit Int.compare a key
    val _ = print ("result = " ^ Int.toString result ^ "\n")								 


    (* Successful search *)
    val key = (2*Int.div(n,2))
    val _ = print ("Looking for: " ^ Int.toString key ^ "\n")
    val result = S.binarySplit Int.compare a key
    val _ = print ("result = " ^ Int.toString result ^ "\n")								 		
  in
    ()
  end


fun testBivariantSplit () = 
  let 
    val a = S.tabulate (fn i => 2*i) n
    val b = S.tabulate (fn i => 2*i + 1) n

    val sa = S.toString Int.toString a
    val sb = S.toString Int.toString b
    val _ = print ("a = " ^ sa ^ "\n")
    val _ = print ("b = " ^ sb ^ "\n")

    val (i, j) = S.bivariantSplit a b (6)
    val _ = print ("split at i        : " ^ 
                   Int.toString i ^ " and " ^ " j = " ^ Int.toString j ^ "\n")

  in
    ()
  end

fun testMerge () = 
  let 
    val a = S.tabulate (fn i => 2*i) n
    val b = S.tabulate (fn i => 2*i + 1) n
    val c = S.mergeSeq a b 
    val sa = S.toString Int.toString a
    val sb = S.toString Int.toString b
    val sc = S.toString Int.toString c
    val _ = print ("a = " ^ sa ^ "\n")
    val _ = print ("b = " ^ sb ^ "\n")
    val _ = print ("c = " ^ sc ^ "\n")						
  in
    ()
  end

fun testSampleSearch () = 
  let 
    val a = S.tabulate (fn i => 2*i) n
    val sa = S.toString Int.toString a
    val _ = print ("a = " ^ sa ^ "\n")
    fun degree n = Real.trunc(Math.sqrt(Real.fromInt n))
    val key = (2*Int.div(n,2) - 1)
    val _ = print ("Looking for: " ^ Int.toString key ^ "\n")
    val result = S.sampleSearch degree Int.compare a key
    val _ =  
      case result of 
        NONE => print ("not found\n")
      | SOME pos => print ("found at position: " ^ Int.toString pos ^ "\n")

    val key = 6
    val _ = print ("Looking for: " ^ Int.toString key ^ "\n")
    val result = S.sampleSearch degree Int.compare a key
    val _ =  
      case result of 
        NONE => print ("not found\n")
      | SOME pos => print ("found at position: " ^ Int.toString pos ^ "\n")
  in
    ()
  end


fun printWork s nested updates evens max sUpdated t scanMax it flat = 
  if n > defaultInput then
    ()
  else
    let 
      fun pairToString (i,j) =
        "(" ^ Int.toString i ^ ", " ^ Int.toString j ^ ")"
      val ss = S.toString Int.toString s
      val sevens = S.toString Int.toString evens
      val supdates = S.toString pairToString updates
      val ssUpdated = S.toString Int.toString sUpdated
      val ts = S.toString Int.toString t
      val its = S.toString Int.toString it
      val snested = S.toString (S.toString Int.toString) nested
      val sflat = S.toString Int.toString flat

      val _ = print ("Sequence is: " ^ ss ^ "\n")
      val _ = print ("Filtered   : " ^ sevens ^ "\n")
      val _ = print ("Max        : " ^ Int.toString max ^ "\n")
      val _ = print ("Scan       : " ^ ts ^ " and scanMax = " ^ Int.toString scanMax ^ "\n")
      val _ = print ("IScan      : " ^ its ^ "\n")
      val _ = print ("Updates   : " ^ supdates ^ "\n")

      val _ = print ("Updated   : " ^ ssUpdated ^ "\n")
      val _ = print ("Nested sequence is: " ^ snested ^ "\n")
      val _ = print ("Flat sequence is  : " ^ sflat ^ "\n")
    in
      ()
    end


val _ = testMerge () 				
(*
val _ = testBinarySearch () 
val _ = testSampleSearch ()
val _ = testBinarySplit () 
val _ = testMerge () 				
val _ = print ("# Begin: Array Sequences, n =" ^ Int.toString n ^ "\n")
val _ = testSampleSearch()
*)
(*
val _ = testBivariantSplit()
*)
(* val s = S.tabulate (fn i => fib (Int.mod (i, 8))) n) *)
(* val nested = S.tabulate (fn i => s) (Int.min (1 + Int.div (n, 1000), 10)) *)

(* val updates = S.tabulate (fn i => (2*Int.div(i, 2), 10*i)) (Int.div (n, 2)) *)
(* val evens = S.filter (fn i => Int.mod(i,2)=0) s *)
(* val max = S.reduce Int.max ~1 s *)
(* val sUpdated = S.inject s updates *)
(* val (t, scanMax) = S.scan Int.max 0 s *)
(* val it = S.iscan Int.max 0 s *)
(* val flat = S.flatten nested *)

(* val () = printWork s  nested updates evens max sUpdated t scanMax it flat *)
val _ = print ("# End: Array Sequences\n")
