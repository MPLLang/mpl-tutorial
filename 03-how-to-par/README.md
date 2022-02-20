# 3. Parallelism and Granularity Control

[(← Hello World)](../02-hello/README.md)

## Preliminaries

Make sure that you've already done the [setup](../01-setup/README.md). If
you're using Docker to run the tutorial, all commands below should be
run within the container in directory `~/mpl-tutoral/03-how-to-par/`:

```
$ cd path/to/mpl-tutorial
$ ./start-container.sh
<container># cd 03-how-to-par
<container># <enter commands here>
```

## Running Example: Parallel Fibonacci

For a running example, we'll use the "hello world" of parallelism:
[Fibonacci numbers](https://en.wikipedia.org/wiki/Fibonacci_number),
calculated using the naive recursive definition
`fib(n) = fib(n-1) + fib(n-2)`. The following code defines this function,
taking a number `n` as input and returning the n<sup>th</sup> Fibonacci number.
The base cases are `n = 0` and `n = 1`.

[`mpl-tutorial/03-how-to-par/sequential/fib.sml`](./sequential/fib.sml):
```sml
fun fib n =
  if n = 0 then
    0
  else if n = 1 then
    1
  else
    fib (n-1) + fib (n-2)
```

<details>
<summary><strong>Question</strong>: I'm new to SML. How do I read this code?</summary>
<blockquote>
In the code above, the first line begins defining a function
named <code>fib</code> that takes an argument <code>n</code>. We then write
the body of the function, which in this case is a conditional expression.
<br><br>
Conditional expressions are written
<code>if B then X else Y</code>, where <code>B</code> is a boolean expression
and <code>X</code> and <code>Y</code> are expressions of the same type.
Note that we compare equality with a single "=", i.e.
<code>n = 0</code> is a boolean expression.
<br><br>
If you are coming from a language such as C, Java, Python, JavaScript, etc.,
then SML is going to feel a bit different. It's a functional language, so
functions are defined by expressions instead of sequences of statements.
</blockquote>
</details>

## Parallelizing it

We can parallelize this code by doing the two recursive calls
in parallel. MPL provides a function for this: `ForkJoin.par`, which takes two
functions as argument and executes them in parallel.

Below is a first attempt, which is "correct" but has a performance issue that
we will discuss below. Notice that we make two recursive
calls, just like before, but now these are packaged up as anonymous functions
and passed as argument to `par`.

[`mpl-tutorial/03-how-to-par/bad-par/bad-par-fib.sml`](./bad-par/bad-par-fib.sml):
```sml
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
```

<details>
<summary><strong>Question</strong>: I'm new to SML. How do I read this code?</summary>
<blockquote>
There are three things in this code we haven't seen before:
<ol>
  <li>
    <code>val (a, b) = ...</code> introduces two variables by unpacking a
    tuple. The right hand side needs to be an expression that returns a
    tuple of two things.
  </li>

  <li>
    <code>let ... in ... end</code> lets us introduce new
    variables locally. In the above code, the variables <code>a</code>
    and <code>b</code> can be used only between the <code>in ... end</code>.
  </li>

  <li>
    <code>fn () => ...</code> is an anonymous (a.k.a. "lambda") function
    that takes no interesting arguments. A more general form is
    <code>fn x => A</code> where <code>A</code> is an expression that uses
    variable <code>x</code>.
  </li>
</ol>
</blockquote>
</details>


**Code to run `badParFib`**. Let's run `badParFib` on input
35 and then prints out the result. In the code below, the function
`Int.toString` converts the resulting number into a string, and the operator
`^` concatenates strings.

[`mpl-tutorial/03-how-to-par/bad-par/main.sml`](./bad-par/main.sml):
```sml
val result = badParFib 35
val _ = print (Int.toString result ^ "\n")
```

**Compile and run it**. Here is an appropriate `.mlb` file for compilation.
The line `$(SML_LIB)/basis/fork-join.mlb` makes it possible to use
`ForkJoin.par`.

[`mpl-tutorial/03-how-to-par/bad-par/main.mlb`](./bad-par/main.mlb):
```sml
$(SML_LIB)/basis/basis.mlb
$(SML_LIB)/basis/fork-join.mlb
bad-par-fib.sml
main.sml
```

We can now compile and run the code. To use more than one processor,
the syntax is `./program @mpl procs N --`.

```
<container># mpl bad-par/main.mlb

<container># time bad-par/main
9227465

real	0m2.432s
user	0m1.843s
sys	0m0.586s

<container># time bad-par/main @mpl procs 2 --
9227465

real	0m1.337s     # about 2x faster on 2 processors!
user	0m1.902s
sys	0m0.579s
```

And check it out: above we can see that this code gets about 2x faster when we
use 2 processors instead of 1.

It's parallel! But is it fast?

## Observed Work-Efficiency and Granularity Control

Ideally, a parallel program should be **work-efficient**: the total amount of
work it performs should be approximately the same as the fastest known
sequential alternative.

We've named `badParFib` suggestively because it has a performance problem.
On one processor, `badParFib` is approximately 10x slower than the simple
sequential `fib` program.

```
<container># mpl sequential/main.mlb
<container># time sequential/main
9227465

real	0m0.216s
user	0m0.213s
sys	0m0.001s

<container># mpl bad-par/main.mlb
<container># time bad-par/main
9227465

real	0m2.432s     # 10x slower than the sequential code!
user	0m1.843s
sys	0m0.586s
```

The only difference between the two programs is `ForkJoin.par`. This function
call isn't free! The cost of `ForkJoin.par` can be fairly significant, and
we need to amortize this overhead.

The simplest way to amortize the cost of `ForkJoin.par` is to ensure that the
parallel tasks we create are not too small. This approach is called
**granularity control**, because we are controlling the so-called
[*granularity*][gran] of tasks (where the "granularity" of a task is just the
amount of work the task performs).

## Making It Fast with Granularity Control

A simple way of performing granularity control for the parallel Fibonacci
function is to switch to a fast sequential algorithm below some
threshold. Here, we hardcode the threshold at `n = 20`: for any `n < 20`, we'll
use the fast sequential `fib(n)` instead of the parallel version.

[`mpl-tutorial/03-how-to-par/fast-par/fast-par-fib.sml`](./fast-par/fast-par-fib.sml):
```sml
fun fastParFib n =
  if n < 20 then
    fib n    (* do the sequential code instead *)
  else
    let
      val (a, b) =
        ForkJoin.par (fn () => fastParFib (n-1),
                      fn () => fastParFib (n-2))
    in
      a + b
    end
```

This is now just as fast as the sequential code on one processor, but is
still parallel. We get the best of both worlds.

```
<container># mpl fast-par/main.mlb
<container># time fast-par/main
9227465

real	0m0.211s      # almost exactly the same as sequential fib!
user	0m0.209s
sys	0m0.001s

<container># time fast-par/main @mpl procs 2 --
9227465

real	0m0.110s      # still gets 2x faster on 2 processors!
user	0m0.215s
sys	0m0.001s
```

[gran]: https://en.wikipedia.org/wiki/Granularity_(parallel_computing)

## Tuning Granularity

Above, we chose a constant threshold `n = 20`. How did we arrive at this
number? What if we used `n = 21` instead? Does that make a difference?

Well, there's no magic here. We just have to try it and measure it. Time for
an experiment!

Below, we generalize our parallel Fibonacci function to take an additional
argument, `g`, which is the grain size. We then switch to the sequential
algorithm when `n < g`. We then run this code on a variety of grain sizes,
and report their times.

[`mpl-tutorial/03-how-to-par/tuning/main.sml`](./tuning/main.sml):
```sml
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
```

When we run it, we see that the running time improves significantly as the
grain size increases, up to around a grain size of 15-20 ish. The difference
between `n = 20` and `n = 25` is small. Choosing `n = 20` as the threshold
seems good enough.

```
<container># mpl tuning/main.mlb
<container># tuning/main
grain 5: 0.861
grain 10: 0.275
grain 15: 0.216
grain 20: 0.213
grain 25: 0.210
```

Keep in mind there is statistical noise to take into account here. A proper
experiment would perform many trials and compare averages. We're being a bit
sloppy, just for the sake of keeping things simple.
