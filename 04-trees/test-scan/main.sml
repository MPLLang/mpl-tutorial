val size = CommandLineArgs.parseInt "size" 100000

val _ = print ("size " ^ Int.toString size ^ "\n")

fun scanSeq tree = Tree.scanSeq (fn (a, b) => a+b) 0 tree
fun scan tree = Tree.scan (fn (a, b) => a+b) 0 tree

val input = Tree.makeBalanced Int64.fromInt 1 (size+1)
val _ =
  print ("built input: height "
         ^ Int.toString (Tree.height input) ^ "\n")

val benchParams = {warmup = 5.0, repeat = 20}
fun run msg f = Benchmark.run benchParams msg f

(* sequential performance *)
val _ = print ("============ sequential ============\n")
val (sums1, total1) = run "scanSeq" (fn () => scanSeq input)

val _ =
  if size > 20 then ()
  else print ("result " ^ Tree.toString Int64.toString sums1 ^ "\n")

(* parallel performance *)
val _ = print ("============= parallel =============\n")
val (sums2, total2) = run "scan" (fn () => scan input)

val _ =
  if size > 20 then ()
  else print ("result " ^ Tree.toString Int64.toString sums2 ^ "\n")

val _ =
  if total1 = total2 then ()
  else Util.die ("whoops: results differ (bug??)")
