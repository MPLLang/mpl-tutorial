val size = CommandLineArgs.parseInt "size" 100000

val _ = print ("size " ^ Int.toString size ^ "\n")

fun sumSeq tree = Tree.reduceSeq (fn (a, b) => a+b) 0 tree
fun sum tree = Tree.reduce (fn (a, b) => a+b) 0 tree

val balancedTree = Tree.makeBalanced Int64.fromInt 0 size

val benchParams = {warmup = 1.0, repeat = 20}
fun run msg f = Benchmark.run benchParams msg f

(* sequential performance *)
val _ = print ("============ sequential ============\n")
val result1 = run "sumSeq(balancedTree)" (fn () => sumSeq balancedTree)

(* parallel performance *)
val _ = print ("============= parallel =============\n")
val result2 = run "sum(balancedTree)" (fn () => sum balancedTree)

val _ =
  if result1 = result2 then ()
  else Util.die ("whoops: results differ (bug??)")
