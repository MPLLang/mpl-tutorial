structure SeqBasis:
sig
  type grain = int

  val tabulate: grain
             -> (int * int)
             -> (int -> 'a)
             -> 'a array

  val foldl: ('b * 'a -> 'b)
          -> 'b
          -> (int * int)
          -> (int -> 'a)
          -> 'b

  val reduce: grain
           -> ('a * 'a -> 'a)
           -> 'a
           -> (int * int)
           -> (int -> 'a)
           -> 'a

  val scan: grain
         -> ('a * 'a -> 'a)
         -> 'a
         -> (int * int)
         -> (int -> 'a)
         -> 'a array  (* length N+1, for both inclusive and exclusive scan *)

  val filter: grain
           -> (int * int)
           -> (int -> 'a)
           -> (int -> bool)
           -> 'a array

  val tabFilter: grain
              -> (int * int)
              -> (int -> 'a option)
              -> 'a array

  val merge: grain
          -> ('a * 'a -> order)
          -> int * int * (int -> 'a)
          -> int * int * (int -> 'a)
          -> 'a array
end =
struct

  type grain = int

  structure A = Array
  structure AS = ArraySlice

  (*
  fun upd a i x = Unsafe.Array.update (a, i, x)
  fun nth a i   = Unsafe.Array.sub (a, i)
  *)

  fun upd a i x = A.update (a, i, x)
  fun nth a i   = A.sub (a, i)

  val parfor = ForkJoin.parfor
  val par = ForkJoin.par
  val allocate = ForkJoin.alloc
  val for = Util.for

  fun tabulate grain (lo, hi) f =
    let
      val n = hi-lo
      val result = allocate n
    in
      if lo = 0 then
        parfor grain (0, n) (fn i => upd result i (f i))
      else
        parfor grain (0, n) (fn i => upd result i (f (lo+i)));

      result
    end

  fun foldl g b (lo, hi) f =
    if lo >= hi then b else
    let
      val b' = g (b, f lo)
    in
      foldl g b' (lo+1, hi) f
    end

  fun reduce grain g b (lo, hi) f =
    if hi - lo <= grain then
      foldl g b (lo, hi) f
    else
      let
        val n = hi - lo
        val k = grain
        val m = Util.ceilDiv n k (* number of blocks *)

        fun red i j =
          case j - i of
            0 => b
          | 1 => foldl g b (lo + i*k, Int.min (lo + (i+1)*k, hi)) f
          | n => let val mid = i + (j-i) div 2
                 in g (par (fn _ => red i mid, fn _ => red mid j))
                 end
      in
        red 0 m
      end

  fun scan grain g b (lo, hi) (f : int -> 'a) =
    if hi - lo <= grain then
      let
        val n = hi - lo
        val result = allocate (n+1)
        fun bump ((j,b),x) = (upd result j b; (j+1, g (b, x)))
        val (_, total) = foldl bump (0, b) (lo, hi) f
      in
        upd result n total;
        result
      end
    else
      let
        val n = hi - lo
        val k = grain
        val m = Util.ceilDiv n k (* number of blocks *)
        val sums = tabulate 1 (0, m) (fn i =>
          let val start = lo + i*k
          in foldl g b (start, Int.min (start+k, hi)) f
          end)
        val partials = scan grain g b (0, m) (nth sums)
        val result = allocate (n+1)
      in
        parfor 1 (0, m) (fn i =>
          let
            fun bump ((j,b),x) = (upd result j b; (j+1, g (b, x)))
            val start = lo + i*k
          in
            foldl bump (i*k, nth partials i) (start, Int.min (start+k, hi)) f;
            ()
          end);
        upd result n (nth partials m);
        result
      end

  fun filter grain (lo, hi) f g =
    let
      val n = hi - lo
      val k = grain
      val m = Util.ceilDiv n k (* number of blocks *)
      fun count (i, j) c =
        if i >= j then c
        else if g i then count (i+1, j) (c+1)
        else count (i+1, j) c
      val counts = tabulate 1 (0, m) (fn i =>
        let val start = lo + i*k
        in count (start, Int.min (start+k, hi)) 0
        end)
      val offsets = scan grain op+ 0 (0, m) (nth counts)
      val result = allocate (nth offsets m)
      fun filterSeq (i, j) c =
        if i >= j then ()
        else if g i then (upd result c (f i); filterSeq (i+1, j) (c+1))
        else filterSeq (i+1, j) c
    in
      parfor 1 (0, m) (fn i =>
        let val start = lo + i*k
        in filterSeq (start, Int.min (start+k, hi)) (nth offsets i)
        end);
      result
    end

  fun tabFilter grain (lo, hi) (f : int -> 'a option) =
    let
      val n = hi - lo
      val k = grain
      val m = Util.ceilDiv n k (* number of blocks *)
      val tmp = allocate n

      fun filterSeq (i,j,k) =
        if (i >= j) then k
        else case f i of
           NONE => filterSeq(i+1, j, k)
         | SOME v => (A.update(tmp, k, v); filterSeq(i+1, j, k+1))

      val counts = tabulate 1 (0, m) (fn i =>
        let val last = filterSeq (lo + i*k, lo + Int.min((i+1)*k, n), i*k)
        in last - i*k
        end)

      val outOff = scan grain op+ 0 (0, m) (fn i => A.sub (counts, i))
      val outSize = A.sub (outOff, m)

      val result = allocate outSize
    in
      (* Choosing grain = n/outSize assumes that the blocks are all
       * approximately the same amount full. We could do something more
       * complex here, e.g. binary search to recursively split up the
       * range into small pieces of all the same size. *)
      parfor (n div (Int.max (outSize, 1))) (0, m) (fn i =>
        let
          val soff = i * k
          val doff = A.sub (outOff, i)
          val size = A.sub (outOff, i+1) - doff
        in
          Util.for (0, size) (fn j =>
            A.update (result, doff+j, A.sub (tmp, soff+j)))
        end);
      result
    end

  fun writeMergeSerial cmp (lo1, hi1, f1) (lo2, hi2, f2) out =
    let
      fun write i x = AS.update (out, i, x)

      (** In the following code,
        *   [i1] is an index for [f1]
        *   [i2] is an index for [f2]
        *   [j] is an index into [out]
        *
        * I wrote this in a way to guarantee that the elements of [f1] and
        * [f2] are each evaluated exactly once.
        *)

      fun finish1 i1 j =
        for (0, hi1-i1) (fn k => write (j+k) (f1 (i1+k)))
      fun finish2 i2 j =
        for (0, hi2-i2) (fn k => write (j+k) (f2 (i2+k)))

      fun loopGet1 i1 (i2, x2) j =
        if i1 >= hi1 then
          (write j x2; finish2 (i2+1) (j+1))
        else
          loop (i1, f1 i1) (i2, x2) j

      and loopGet2 (i1, x1) i2 j =
        if i2 >= hi2 then
          (write j x1; finish1 (i1+1) (j+1))
        else
          loop (i1, x1) (i2, f2 i2) j

      and loop (i1, x1) (i2, x2) j =
        if cmp (x1, x2) = GREATER then
          (write j x2; loopGet2 (i1, x1) (i2+1) (j+1))
        else
          (write j x1; loopGet1 (i1+1) (i2, x2) (j+1))

    in
      if lo1 >= hi1 then
        finish2 lo2 0
      else if lo2 >= hi2 then
        finish1 lo1 0
      else
        loop (lo1, f1 lo1) (lo2, f2 lo2) 0
    end

  fun binarySearch cmp (lo, hi, f) x =
    if lo >= hi then
      lo
    else
      let
        val mid = lo + (hi-lo) div 2
      in
        case cmp (x, f mid) of
          LESS =>
            binarySearch cmp (lo, mid, f) x
        | GREATER =>
            binarySearch cmp (mid+1, hi, f) x
        | EQUAL =>
            mid
      end

  fun writeMerge grain cmp (s1 as (lo1, hi1, f1)) (s2 as (lo2, hi2, f2)) out =
    if (hi1-lo1) + (hi2-lo2) <= grain then
      writeMergeSerial cmp s1 s2 out
    else if lo1 >= hi1 then
      parfor grain (lo2, hi2) (fn i2 => AS.update (out, i2-lo2, f2 i2))
    else
      let
        val mid1 = lo1 + (hi1 - lo1) div 2
        val pivot = f1 mid1
        val mid2 = binarySearch cmp s2 pivot

        val outMid = (mid1-lo1)+(mid2-lo2)
        val outLeft = ArraySlice.subslice (out, 0, SOME outMid)
        val outRight = ArraySlice.subslice (out, 1+outMid, NONE)
      in
        ArraySlice.update (out, outMid, pivot);

        par (fn _ => writeMerge grain cmp (lo1, mid1, f1) (lo2, mid2, f2) outLeft,
             fn _ => writeMerge grain cmp (mid1+1, hi1, f1) (mid2, hi2, f2) outRight);

        ()
      end

  fun merge grain cmp (s1 as (lo1, hi1, f1)) (s2 as (lo2, hi2, f2)) =
    let
      val n1 = hi1-lo1
      val n2 = hi2-lo2
      val result = allocate (n1+n2)
    in
      writeMerge grain cmp s1 s2 (AS.full result);
      result
    end

end
