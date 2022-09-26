(* Usage: examples -n <sequence length> *)

structure S = ArraySequence
structure CLA = CommandLineArgs

val defaultInput = 9
val n = CLA.parseInt "n" defaultInput


fun test_bisplit () = 
  let 
    val a = S.tabulate (fn i => 2*i) n
    val b = S.tabulate (fn i => 2*i + 1) n

    val sa = S.toString Int.toString a
    val sb = S.toString Int.toString b
    val _ = print ("a = " ^ sa ^ "\n")
    val _ = print ("b = " ^ sb ^ "\n")

    val (i, j) = S.bisplit a b (6)
    val _ = print ("split at i        : " ^ 
                   Int.toString i ^ " and " ^ " j = " ^ Int.toString j ^ "\n")

  in
    ()
  end

fun test_samplesearch () = 
  let 
    val a = S.tabulate (fn i => 2*i) n
    val sa = S.toString Int.toString a
    val _ = print ("a = " ^ sa ^ "\n")

    val degree n = 4 
    val result = S.sampleSearch a degree Int.compare a (2*Int.div(n,2) - 1)
  in
    case result of 
      NONE => print ("not found")
    | SOME pos => print ("found at position: " ^ Int.toString pos ^ "\n")
  end

fun sampleSearch (degree: int -> int) (cmp: 'a * 'a -> order) (a: 'a t) (k: a): int option =

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
