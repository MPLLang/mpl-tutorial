structure AdjInt =
struct
  type 'a seq = 'a Seq.t

  structure G = AdjacencyGraph(Int)
  structure AS = ArraySlice
  structure DS = DelayedSeq


  (* fun sumOfOutDegrees frontier =
    SeqBasis.reduce 10000 op+ 0 (0, Seq.length frontier) (degree o Seq.nth frontier)
    (* DS.reduce op+ 0 (DS.map degree (DS.fromArraySeq frontier)) *)

  fun shouldProcessDense frontier =
    let
      val n = Seq.length frontier
      val m = sumOfOutDegrees frontier
    in
      n + m > denseThreshold
    end *)

  fun should_process_sparse g V =
    let
      val denseThreshold = G.numEdges g div 20
      val totalOutDegree =
        SeqBasis.reduce 10000 op+ 0 (0, Seq.length V) (G.degree g o Seq.nth V)
      val n = Seq.length V
      val m = totalOutDegree
    in
      n + m <= denseThreshold
    end


  fun edge_map_dense g vertices f h =
    let
      val inFrontier = Seq.tabulate (fn _ => false) (G.numVertices g)
      val _ = Seq.foreach vertices (fn (_, v) =>
        ArraySlice.update (inFrontier, v, true))

      fun processVertex v =
        if not (h v) then NONE
        else
          let
            val neighbors = G.neighbors g v
            fun loop i =
              if i >= Seq.length neighbors then NONE else
              let val u = Seq.nth neighbors i
              in
                if not (Seq.nth inFrontier u) then
                  loop (i+1)
                else
                case f (u, v) of
                  NONE => loop (i+1)
                | SOME x => SOME x
              end
          in
            loop 0
          end
    in
      AS.full (SeqBasis.tabFilter 100 (0, G.numVertices g) processVertex)
    end


  fun edge_map_sparse g vertices f h =
    let
      fun app_vertex u =
        let
          val all_ngbrs = (G.neighbors g u)
          fun ds i =  let
                        val v = Seq.nth all_ngbrs i
                      in
                        if h (v) then f (u, v)
                        else NONE
                      end
          val m = SeqBasis.tabFilter 10000 (0, Seq.length all_ngbrs) ds
        in
          DS.fromArraySeq (AS.full m)
        end
    in
      DS.toArraySeq (DS.flatten (DS.map app_vertex (DS.fromArraySeq vertices)))
    end

  fun edge_map g V f h =
    if should_process_sparse g V then
      edge_map_sparse g V f h
    else
      edge_map_dense g V f h

  fun contract clusters g =
    let
      val n = G.numVertices g
      val vertices = Seq.tabulate (fn u => u) n
      val has_neighbor = Seq.tabulate (fn i => 0) n

      fun upd (u, v) =
        let
          val (cu, cv) = ((Seq.nth clusters u), (Seq.nth clusters v))
        in
          if cu = cv then NONE
          else (AS.update (has_neighbor, cu, 1); SOME (cu, cv))
        end
      val sorted_edges = G.dedupEdges (edge_map g vertices upd (fn _ => true))
      val (vmap, num_taken) = Seq.scan Int.+ 0 has_neighbor
      val new_sorted_edges = Seq.map (fn (x, y) => (Seq.nth vmap x, Seq.nth vmap y)) sorted_edges

      fun new_label c =
        let
          val is_taken = (Seq.nth has_neighbor c) = 1
          val num_taken_left = Seq.nth vmap c
        in
          if is_taken then num_taken_left
          else num_taken + (c - num_taken_left)
        end
    in
      (G.fromSortedEdges new_sorted_edges, new_label)
    end
end
