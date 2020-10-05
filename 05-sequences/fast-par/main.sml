structure S = ArraySequence
val million = 1000000
val n = 10 * million
val s = S.tabulate (fn i => Int.mod (i, 100)) n
val f = S.filter (fn i => Int.mod(i,2)=0) s
val max = S.reduce Int.max ~1 s
val (t, total) = S.scan (fn (i, j) => i+j) 0 s
val _ = print ("Max : " ^ Int.toString max ^ "\n")
