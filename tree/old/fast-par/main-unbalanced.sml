val million = 1000000
val n = 10 * million
val tree = Tree.mk_unbalanced n
val result = Tree.height tree
val _ = print (Int.toString result ^ "\n")
