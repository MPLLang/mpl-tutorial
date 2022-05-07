(* bfs.sml
 * A parallel implementation of BFS based on sequence primitives
 * This implementation does not use concurrency primitives such as cas
 * It relies on sequence inject instead 
 *)
structure ParCASBFS =
struct
  exception InternalError

  structure G = AdjacencyGraph(Int)
  structure S = ArraySequence 

  fun bfs g s: int S.seq =
    let
      fun neighbors v = G.neighbors g v
      fun degree v = G.degree g v

      val n = G.numVertices g
      val m = G.numEdges g

      fun search (visited, frontier: int S.seq) =
        if Seq.length(frontier) = 0 then
          visited
        else
          let 

            fun claim (u, v) = 
                Array.sub (visited, u) = ~1
                andalso
                ~1 = Concurrency.casArray (visited, u) (~1, v) 

            fun visit(v) = 
              S.filterSafe (fn u => claim (u, v)) (neighbors v)

            val frontier' = S.flatten (S.map visit frontier)
          in
            search (visited, frontier')
          end 
           

      val visited: int Array.array = Array.tabulate (n, fn i => if i = s then s else ~1)
      val frontier = S.singleton s
      val visited' = search (visited, frontier)
    in
      S.fromArray visited'
    end

end
