structure S = ArraySequence
val _ = print "# SMALL example:\n"
val n = 9
val s = S.tabulate (fn i => i) n
val ss = S.toString Int.toString s
val (t, total) = S.scan (fn (i, j) => i+j) 0 s
val st = S.toString Int.toString t
val _ = print ("Sequence is: " ^ ss ^ "\n")
val _ = print ("Scan     is: " ^ st ^ " and total = " ^ Int.toString total ^ "\n")
