val _ = print "# Large example:\n"
val million = 1000000
val n = 10 * million
val tree = Tree.mkBalanced n
val _ = print "."
val h = Tree.height tree
val _ = print "."
val tree_f_opt = Tree.filter (fn x => Int.mod(x, 2) = 0) tree
val _ = print "."
val (prefixSums, _) = Tree.scan 0 (fn (x, y) => Int.mod(x + y, million)) tree 
val _ = print ".\n"
val _ = print ("Height of filtered unbalanced tree is: " ^ Int.toString h ^ "\n")
