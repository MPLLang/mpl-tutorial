# 3. Parallel Fibonacci

[(← Hello World)](../02-hello/README.md) [(Mergesort →)](../04-mergesort/README.md)

The following defines a function `fib` which takes a number `n` as input
and returns the n<sup>th</sup>
[Fibonacci number](https://en.wikipedia.org/wiki/Fibonacci_number).

[fib.sml](./fib.sml):
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

We can make this code faster by doing the two recursive calls
(`fib (n-1)` and `fib (n-2)`) in parallel. MPL provides a function for this:
`ForkJoin.par`, which takes two functions as argument and executes them in
parallel.

Below is a first attempt, which is "correct" but has a performance issue that
we will discuss below. Notice that we make two recursive
calls, just like before, but now these are packaged up as anonymous functions
and passed as argument to `par`.

[bad-par-fib.sml](./bad-par-fib.sml):
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

**Code to run `badParFib`**. Below is code which runs `badParFib` (on input
35) and then prints out the result. The function `Int.toString` converts the
resulting number into a string, and the operator `^` concatenates strings.

[bad-par-fib-main.sml](./bad-par-fib-main.sml):
```sml
val result = badParFib 35
val _ = print (Int.toString result ^ "\n")
```

**Compile and run it**. Below is an appropriate `.mlb` file.
The line `$(SML_LIB)/basis/fork-join.mlb` makes it possible to use
`ForkJoin.par`.

[bad-par-fib.mlb](./bad-par-fib.mlb):
```sml
$(SML_LIB)/basis/basis.mlb
$(SML_LIB)/basis/fork-join.mlb
bad-par-fib.sml
bad-par-fib-main.sml
```

We can now compile and run the code. To use more than one processor,
the syntax is `./program @mpl procs N --`.

```
$ mpl bad-par-fib.mlb
$ ./bad-par-fib
9227465
$ ./bad-par-fib @mpl procs 2 --  # use 2 processors... it gets about 2x faster!
9227465
```

## Making it fast

The `badParFib` function has a problem: on one processor, it's much slower than
the simple sequential `fib` program.

TODO... continue from here...
