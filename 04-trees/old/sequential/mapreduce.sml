fun pairToString (i, j) = 
  "(" ^ (Int.toString i) ^ ", " ^ (Int.toString j) ^ ")"

val _ = print "# Small example:\n"
val tree = Tree.mkBalanced 10
val tree2 = Tree.map (fn i => (i, i)) tree
val max = Tree.reduce (fn ((x, y), (a, b)) => (Int.max (x, a), Int.max (y, b))) 
                      (0, 0)
                      tree2
val _ = print ("Balanced tree is: " ^ Tree.toString Int.toString tree ^ "\n")
val _ = print ("Balanced tree2 is: " ^ Tree.toString pairToString tree2 ^ "\n")
val _ = print ("Max is: " ^ pairToString max ^ "\n")

val _ = print "# Big example:\n"
val million = 1000000
val n =  million
val tree = Tree.mkBalanced n
val tree2 = Tree.map (fn i => (i, i)) tree
val max = Tree.reduce (fn ((x, y), (a, b)) => (Int.max (x, a), Int.max (y, b))) 
                      (0, 0)
                      tree2
val _ = Tree.mkBalanced n
val _ = print ("Max of balanced tree is: " ^ pairToString max ^ "\n")
