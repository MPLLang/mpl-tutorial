structure Util =
struct

  fun getTime f =
    let
      val t0 = Time.now ()
      val result = f ()
      val t1 = Time.now ()
    in
      (result, Time.- (t1, t0))
    end

  fun ceilDiv n k =
    1 + (n-1) div k

  fun for (i, j) f =
    if i >= j then
      ()
    else
      (f i; for (i+1, j) f)

end
