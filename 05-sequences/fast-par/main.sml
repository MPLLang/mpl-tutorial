(* Usage: main -n <sequence length> *)

structure CLA = CommandLineArgs
structure S = ArraySequence

val defaultInput = 1024 * 1024
val n = CLA.parseInt "n" defaultInput
val _ = print("Tabulating an array of " ^ Int.toString n ^ " integers\n")
val s = S.tabulate (fn i => Int.mod (i, 100)) n
val _ = print("Filtering\n")
val f = S.filter (fn i => Int.mod(i,2)=0) s
val _ = print("Reducing\n")
val max = S.reduce Int.max ~1 s
val _ = print("Scanning\n")
val (t, total) = S.scan (fn (i, j) => i+j) 0 s
val _ = print("IScanning\n")
val it = S.iscan (fn (i, j) => i+j) 0 s
val _ = print ("Max : " ^ Int.toString max ^ "\n")

val nested = S.tabulate (fn i => s) 10
val flat = S.flatten nested
