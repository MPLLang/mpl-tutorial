(* Usage: examples -n <sequence length> *)

structure S = ArraySequence
structure CLA = CommandLineArgs

val defaultInput = 9
val n = CLA.parseInt "n" defaultInput

fun optIntToString oi = 
  case oi of 
    NONE => "NONE"
  | SOME i => "SOME " ^ Int.toString i

fun iteratePrefixes f b s =
  let 
    fun g ((l, b), a) = (b::l, f(b, a))
    val (l, r) = S.iterate g ([], b) s
  in 
    (S.fromList (List.rev l), r)
  end


fun mcssSeq a = 
  (* Kanade's linear-time sequential algorithm *)
  let
    fun f(sum, x) = 
      case sum of 
        NONE => SOME x
      | SOME sum =>
        if sum + x >= x then
          SOME (sum + x)
        else
          SOME x

    val (b, totalopt) = iteratePrefixes f NONE a

    fun maxOpt (x,y) =
      case (x, y) of
        (NONE, y) => y
      | (x, NONE) => x
      | (SOME x, SOME y) => if x > y then SOME x else SOME y

    val bs = S.toString optIntToString b
    val mo = S.reduce maxOpt NONE b
    val _ = print ("prefixes = " ^ bs ^ " \n")
    val _ = print ("totalopt = " ^ optIntToString totalopt ^ " \n")

  in
    maxOpt (mo, totalopt)
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



val _ = print ("# Begin: MCSS n =" ^ Int.toString n ^ "\n")
val s = S.tabulate (fn i => (Util.hash i) mod n - (Util.hash (2*n+i+1))  mod n) n
val _ = print ("# Calculating mcss\n")
val r = mcssSeq s
val ss = S.toString Int.toString s
val _ = print ("# mcss of " ^ ss ^ " = " ^ optIntToString r ^ "\n")
val _ = print ("# End: MCSS\n")
