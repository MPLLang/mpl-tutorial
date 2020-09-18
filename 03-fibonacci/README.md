# 3. Parallel Fibonacci

[(← Hello World)](../02-hello) [(Mergesort →)](../04-mergesort)

The following defines a function `fib` which takes a number `n` as input
and returns the n<sup>th</sup>
[Fibonacci numbers](https://en.wikipedia.org/wiki/Fibonacci_number).

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

We can make this code faster by doing the two recursive calls
(`fib (n-1)` and `fib (n-2)`) in parallel. MPL provides a function for this:
`ForkJoin.par`, which takes two functions and executes them in parallel.

Below is a first attempt...

[bad-par-fib.sml](./bad-par-fib.sml)
```sml
fun badParFib n =
  if n = 0 then
    0
  else if n = 1 then
    1
  else
    let
      val (a, b) =
        ForkJoin.par (fn () => badParFib (n-1), fn () => badParFib (n-2))
    in
      a + b
    end
```
