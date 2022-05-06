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
              (* claim u via v *)
              let
                val _ = print ("Claiming " ^ Int.toString u ^ " via " ^ Int.toString v ^ "\n")
                val claimed = 
                Array.sub (visited, u) = ~1
                andalso
                ~1 = Concurrency.casArray (visited, u) (~1, v) 
                val _ = print ("Claimed: " ^ Bool.toString claimed ^ "\n")
              in
                claimed
              end

            fun visit(v) = 
              let
                val ns = neighbors v
                val _ = print ("Neighbors " ^ S.toString Int.toString ns ^ "\n")         
                val fns =  S.filter (fn u => claim (u, v)) ns
                val _ = print ("Neigbors filtered " ^ S.toString Int.toString fns ^ "\n")
              in
                fns
              end 

            val _ = print ("Frontier " ^ S.toString Int.toString frontier ^ "\n")
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
