val size = CommandLineArgs.parseInt "size" 1000

fun sumSeq tree = Tree.reduceSeq (fn (a, b) => a+b) 0 tree
fun sum tree = Tree.reduce (fn (a, b) => a+b) 0 tree

val tree1 = Tree.makeUnbalanced Int64.fromInt 0 size
val tree2 = Tree.makeBalanced Int64.fromInt 0 size

(* sequential performance *)
val (result1, tm1) = Util.getTime (fn () => sumSeq tree1)
val (result2, tm2) = Util.getTime (fn () => sumSeq tree2)

val _ = print ("==== sequential ====\n")
val _ = print ("sumSeq(unbalancedTree) = " ^ Int64.toString result1 ^ ";  finished in " ^ Time.toString tm1 ^ "s\n")
val _ = print ("sumSeq(balancedTree) = " ^ Int64.toString result2 ^ ";  finished in " ^ Time.toString tm2 ^ "s\n")

(* parallel performance *)
val (result1, tm1) = Util.getTime (fn () => sum tree1)
val (result2, tm2) = Util.getTime (fn () => sum tree2)

val _ = print ("==== parallel ====\n")
val _ = print ("sum(unbalancedTree) = " ^ Int64.toString result1 ^ ";  finished in " ^ Time.toString tm1 ^ "s\n")
val _ = print ("sum(balancedTree) = " ^ Int64.toString result2 ^ ";  finished in " ^ Time.toString tm2 ^ "s\n")
