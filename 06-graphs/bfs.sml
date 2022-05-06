(* Usage: main <input file> [-source <vertex number>] [--check] 
 * Example: main inputs/rmat-1K-symm -source 0 --check
 *)

structure CLA = CommandLineArgs
structure G = AdjacencyGraph(Int)

structure SBFS = SequentialBFS
structure PBFS = ParBFS
structure PCASBFS = ParCASBFS
structure DBFS = DoptBFS

val usage = "bfs <filename> <mode: seq | dopt | par | parcas> [--source <number>] [--check]"
val source = CLA.parseInt "source" 0
val doCheck = CLA.parseFlag "check"


val (filename, mode) =
  case CLA.positional () of
    [x,y] => (x, y)
  | _ => Util.die usage


fun readGraph(filename) = 
  let 
    val (graph, tm) = Util.getTime (fn _ => G.parseFile filename)
    val _ = print ("num vertices: " ^ Int.toString (G.numVertices graph) ^ "\n")
    val _ = print ("num edges: " ^ Int.toString (G.numEdges graph) ^ "\n")
    val _ = print ("source: " ^ Int.toString source ^ "\n")
    val _ = print ("check for correctness: " ^ (if doCheck then "yes" else "no") ^ "\n")
    val (_, tm) = Util.getTime (fn _ =>
      if G.parityCheck graph then ()
      else TextIO.output (TextIO.stdErr,
        "WARNING: parity check failed; graph might not be symmetric " ^
        "or might have duplicate- or self-edges\n"))
    val _ = print ("parity check in " ^ Time.fmt 4 tm ^ "s\n")
  in
    graph
  end

fun numHops P hops v =
  if hops > Seq.length P then ~2
  else if Seq.nth P v = ~1 then ~1
  else if Seq.nth P v = v then hops
  else numHops P (hops+1) (Seq.nth P v)


fun check graph source P =
  let
    val (P', sequentialTime) =
      Util.getTime (fn _ => SBFS.bfs graph source)

    val correct =
      Seq.length P = Seq.length P'
      andalso
      SeqBasis.reduce 10000 
        (fn (a, b) => a andalso b) 
        true 
        (0, Seq.length P)
        (fn i => numHops P 0 i = numHops P' 0 i)
  in
    print ("sequential finished in " ^ Time.fmt 4 sequentialTime ^ "s\n");
    print ("correct? " ^ (if correct then "yes" else "no") ^ "\n")
  end


fun runBFS graph source bfs =  
  let 
    fun numHops P hops v =
      if hops > Seq.length P then ~2
      else if Seq.nth P v = ~1 then ~1
      else if Seq.nth P v = v then hops
      else numHops P (hops+1) (Seq.nth P v)

    val P = Benchmark.run "running bfs" (fn _ => bfs graph source)

    val numVisitedSeq =
      SeqBasis.reduce 10000 op+ 0 (0, Seq.length P)
        (fn i => if Seq.nth P i >= 0 then 1 else 0)
    val _ = print ("visited " ^ Int.toString numVisitedSeq ^ "\n")

    val maxHops =
      SeqBasis.reduce 100 Int.max ~3 (0, G.numVertices graph) (numHops P 0)
    val _ = print ("max dist " ^ Int.toString maxHops ^ "\n")

  in 
    if doCheck then check graph source P else ()
  end

val graph = readGraph(filename)

val () = if mode = "seq" then
           runBFS graph source SBFS.bfs
         else if mode = "dopt" then
           runBFS graph source DBFS.bfs
         else if mode = "parcas" then
           runBFS graph source PCASBFS.bfs
         else if mode = "par" then
           runBFS graph source PBFS.bfs
         else
           print ("Incorrect mode:" ^ usage)

val _ = GCStats.report ()
