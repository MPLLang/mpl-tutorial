fun fastParFib n =
  if n < 20 then
    fib n
  else
    let
      val (a, b) =
        ForkJoin.par (fn () => fastParFib (n-1),
                      fn () => fastParFib (n-2))
    in
      a + b
    end
