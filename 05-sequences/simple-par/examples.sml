structure S = ArraySequence
val _ = print "# SMALL example:\n"
val n = 9
val s = S.tabulate (fn i => i) n
val nested = S.tabulate (fn i => s) n
val f = S.filter (fn i => Int.mod(i,2)=0) s
val max = S.reduce Int.max ~1 s
val (t, total) = S.scan (fn (i, j) => i+j) 0 s
val it = S.iscan (fn (i, j) => i+j) 0 s
val flat = S.flatten nested
val ss = S.toString Int.toString s
val fs = S.toString Int.toString f
val ts = S.toString Int.toString t
val its = S.toString Int.toString it
val snested = S.toString (S.toString Int.toString) nested
val sflat = S.toString Int.toString flat
val _ = print ("Sequence is: " ^ ss ^ "\n")
val _ = print ("Filtered   : " ^ fs ^ "\n")
val _ = print ("Max        : " ^ Int.toString max ^ "\n")
val _ = print ("Scan       : " ^ ts ^ " and total = " ^ Int.toString total ^ "\n")
val _ = print ("IScan      : " ^ its ^ "\n")
val _ = print ("Nested sequence is: " ^ snested ^ "\n")
val _ = print ("Flat sequence is  : " ^ sflat ^ "\n")
