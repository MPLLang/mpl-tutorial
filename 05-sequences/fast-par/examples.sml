structure S = ArraySequence
val _ = print "# SMALL example:\n"
val n = 9
val s = S.tabulate (fn i => i) n
val f = S.filter (fn i => Int.mod(i,2)=0) s
val (t, total) = S.scan (fn (i, j) => i+j) 0 s
val ss = S.toString Int.toString s
val fs = S.toString Int.toString f
val ts = S.toString Int.toString t
val _ = print ("Sequence is: " ^ ss ^ "\n")
val _ = print ("Filtered   : " ^ fs ^ "\n")
val _ = print ("Scan     is: " ^ ts ^ " and total = " ^ Int.toString total ^ "\n")
