structure CLA = CommandLineArgs

val size = CLA.parseInt "size" 1000000

fun elem i = i

val (tree, tm) = Util.getTime (fn _ => Tree.makeBalanced elem size)
val _ = print ("makeBalanced(" ^ Int.toString size ^ "): " ^ Time.toString tm ^ "s\n")
