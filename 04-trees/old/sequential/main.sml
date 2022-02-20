val _ = print "# Small example:\n"
val tree = Tree.mkBalanced 10
val _ = print ("Balanced tree is: " ^ Tree.toString Int.toString tree ^ "\n")
val _ = print ("Height of balanced tree is: " ^ Int.toString (Tree.height tree) ^ "\n")

val tree = Tree.mkUnbalanced 10
val _ = print ("Unbalanced tree is: " ^ Tree.toString Int.toString tree ^ "\n")
val _ = print ("Height of unbalanced tree is: " ^ Int.toString (Tree.height tree) ^ "\n")

val _ = print "# Big example:\n"
val million = 1000000
val n = 10 * million
val tree = Tree.mkBalanced n
val _ = Tree.mkBalanced n
val _ = print ("Height of balanced tree is: " ^ Int.toString (Tree.height tree) ^ "\n")
