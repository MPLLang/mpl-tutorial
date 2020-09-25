structure Util =
struct

  fun ceilDiv n k =
    1 + (n-1) div k

  fun for (i, j) f =
    if i >= j then
      ()
    else
      (f i; for (i+1, j) f)

end
