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

(* run f(i), f(i+1), ..., f(j-1) *)
fun forloop (i, j, f) =
  if i >= j then () else (f i; forloop (i+1, j, f))

(** this is the same as
  *   (timeFibWithGrain 5;
  *    timeFibWithGrain 10;
  *    timeFibWithGrain 15;
  *    timeFibWithGrain 20;
  *    timeFibWithGrain 25;
  *    timeFibWithGrain 30)
  *)
val _ = forloop (1, 7, fn i => timeFibWithGrain (5*i))
