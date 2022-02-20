fun parFibWithGrain (g, n) =
  if n < g then
    fib n
  else
    let
      val (a, b) =
        ForkJoin.par (fn () => parFibWithGrain (g, n-1),
                      fn () => parFibWithGrain (g, n-2))
    in
      a + b
    end

fun timeFibWithGrain g =
  let
    val n = 35

    val t0 = Time.now ()
    val result = parFibWithGrain (g, n)
    val t1 = Time.now ()

    val elapsed = Time.- (t1, t0)
  in
    print ("grain " ^ Int.toString g ^ ": " ^ Time.toString elapsed ^ "\n")
  end

val _ = timeFibWithGrain 5
val _ = timeFibWithGrain 10
val _ = timeFibWithGrain 15
val _ = timeFibWithGrain 20
val _ = timeFibWithGrain 25
