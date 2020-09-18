# 2. Hello World

[(← Setup)](../01-setup) [(Fibonacci →)](../03-fibonacci)

## Write it

Our first program is a one-liner.

[hello.sml](./hello.sml):
```
val _ = print "hello world!\n"
```

The function `print` takes a string as argument and writes it to the terminal.

<details>
<summary><strong>Question</strong>: what does <code>val _ =</code> mean?</summary>
<blockquote>
Normally, we use the syntax <code>val ... = ...</code> to introduce a new
variable. For example, <code>val x = 2+2</code> lets us use <code>x</code> to
refer to the value 4.
But in this case, <code>print</code> doesn't return anything interesting, so we
just write <code>val _ = print ...</code> which means "print the thing, but
don't introduce a new variable to refer to the result".
</blockquote>
</details>

## Compile and run it

To the compile this file, pass it to `mpl` at the command-line. This produces
an executable called `hello`. (By default, `mpl` names the executable the same
as the source file.)

```
$ mpl hello.sml
$ ./hello
hello world!
```

