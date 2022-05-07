(* Usage: examples -n <sequence length> *)

structure S = ArraySequence
structure CLA = CommandLineArgs

val defaultInput = 9
val n = CLA.parseInt "n" defaultInput


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

val _ = print ("# Begin: Array Sequences, n =" ^ Int.toString n ^ "\n")
val s = S.tabulate (fn i => i) n
val nested = S.tabulate (fn i => s) (Int.min (1 + Int.div (n, 1000), 10))

val updates = S.tabulate (fn i => (2*Int.div(i, 2), 10*i)) (Int.div (n, 2))
val evens = S.filter (fn i => Int.mod(i,2)=0) s
val max = S.reduce Int.max ~1 s

val sUpdated = S.inject s updates
val (t, scanMax) = S.scan Int.max 0 s
val it = S.iscan Int.max 0 s
val flat = S.flatten nested

val () = printWork s  nested updates evens max sUpdated t scanMax it flat 
val _ = print ("# End: Array Sequences\n")
