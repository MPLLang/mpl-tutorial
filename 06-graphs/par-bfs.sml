(* bfs.sml
 * A parallel implementation of BFS based on sequence primitives
 * This implementation does not use concurrency primitives such as cas
 * It relies on sequence inject instead 
 *)
structure ParBFS =
struct
  exception InternalError

  structure G = AdjacencyGraph(Int)
  structure S = ArraySequence 

  fun fib n = 
    if n <= 1 then n
    else fib (n-1) + fib (n-2)

  fun bfs g s: int S.seq =
    let
      fun neighbors v = G.neighbors g v
      fun degree v = G.degree g v

      val n = G.numVertices g
      val m = G.numEdges g

      fun search (visited: int S.seq, frontier: int S.seq) =
        if Seq.length(frontier) = 0 then
          visited
        else
          let 
            fun status visited u = 
              S.nth visited u

            fun f(v) = 
              S.filtermap 
                (fn u => status visited u = ~1) 
                (fn u => (u, v)) 
                (neighbors v)

            val edges = S.flatten (S.map f frontier)
            val visited' = S.inject (visited, edges)
            val frontier' = S.filtermap
                            (fn (u, v) => status visited' u = v) edges
                            (fn (u, v) => u)
          in
            search (visited', frontier')
          end 
           

      val visited = S.tabulate (fn i => if i = s then s else ~1) n
      val frontier = S.singleton s
      val visited' = search (visited, frontier)
    in
      visited'
    end

end
