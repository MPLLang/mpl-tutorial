val _ = print "# Small example:\n"
val tree = Tree.mkBalanced 10
val SOME tree_f = Tree.filter (fn x => Int.mod(x, 2) = 0) tree
val prefixSums = Tree.scan 0 (fn (x, y) => x + y) tree 
val _ = print ("Balanced tree is: " ^ Tree.toString Int.toString tree ^ "\n")
val _ = print ("Balanced tree (filtered) is: " ^ Tree.toString Int.toString tree_f ^ "\n")
val _ = print ("Balanced tree (scan) is: " ^ Tree.toString Int.toString prefixSums ^ "\n")
val _ = print ("Height of balanced tree is: " ^ Int.toString (Tree.height tree) ^ "\n")
val _ = print ("Height of filtered balanced tree is: " ^ Int.toString (Tree.height tree_f) ^ "\n")


val tree = Tree.mkUnbalanced 10
val SOME tree_f = Tree.filter (fn x => Int.mod(x, 2) = 0) tree
val prefixSums = Tree.scan 0 (fn (x, y) => x + y) tree 
val _ = print ("Unbalanced tree is: " ^ Tree.toString Int.toString tree ^ "\n")
val _ = print ("Unbalanced tree (filtered) is: " ^ Tree.toString Int.toString tree_f ^ "\n")
val _ = print ("Unbalanced tree (scan) is: " ^ Tree.toString Int.toString prefixSums ^ "\n")
val _ = print ("Height of unbalanced tree is: " ^ Int.toString (Tree.height tree) ^ "\n")
val _ = print ("Height of filtered unbalanced tree is: " ^ Int.toString (Tree.height tree_f) ^ "\n")

val _ = print "# Large example:\n"
val million = 1000000
val n = 10 * million
val tree = Tree.mkBalanced n
val result = Tree.height tree
val _ = print ("Height of filtered unbalanced tree is: " ^ Int.toString result ^ "\n")
