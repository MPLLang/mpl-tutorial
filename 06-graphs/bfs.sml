structure BFS =
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

      fun search (visited: int S.seq, frontier: int S.seq) =
        if Seq.length(frontier) = 0 then
          visited
        else
          let 
            fun status visited u = 
              S.nth visited u

            fun f(v) = 
              let 
                val freshNeighbors = S.filter (fn u => status visited u = ~1) (neighbors v)
              in
                S.map (fn u => (u, v)) freshNeighbors
              end

            val edges = S.flatten (S.map f frontier)
            val visited' = S.inject (visited, edges)
            val winners = S.filter (fn (u, v) => status visited' u = v) edges
            val frontier' = S.map (fn (u, v) => u) winners
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
