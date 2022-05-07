fun badParFib n =
  if n = 0 then
    0
  else if n = 1 then
    1
  else
    let
      val (a, b) =
        ForkJoin.par (fn () => badParFib (n-1),
                      fn () => badParFib (n-2))
    in
      a + b
    end
