# 2. Hello World

[(← Setup)](../01-setup) [(Fibonacci →)](../03-fibonacci)

## Write it

Our first program is a one-liner: the function `print` takes a string as
argument and writes it to the terminal.

[hello.sml](./hello.sml):
```sml
val _ = print "hello world\n"
```

Note that in SML, it is common to call a function without putting parentheses
around its arguments (e.g. `f x` instead of `f(x)`).

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
an executable called `hello`.

```console
$ mpl hello.sml
$ ./hello
hello world
```

By default, `mpl` names the executable the same as the source file. We can
tell it to use a different name with the `-output` flag:

```console
$ mpl -output foobar hello.sml
$ ./foobar
hello world
```

## Compiling multiple files as one program

Typically, we don't write programs as just a single `.sml` file. Instead,
we write multiple separate files and then put them together to make a program.
To do so with MPL, we need to write an additional file that describes how to put
the files together. This additional file is called an
[ML Basis File](http://mlton.org/MLBasis), and has the extension `.mlb`.

For example, there is a second file [`hello-again.sml`](./hello-again.sml)
in this directory that prints another message to the terminal.
The following `.mlb` tells MPL to first run
[hello.sml](./hello.sml) and then
[hello-again.sml](./hello-again.sml).

[hello-twice.mlb](./hello-twice.mlb):
```sml
$(SML_LIB)/basis/basis.mlb
hello.sml
hello-again.sml
```

<details>
<summary><strong>Question</strong>: what the heck does <code>$(SML_LIB)/basis/basis.mlb</code> mean?</summary>
<blockquote>
This line tells MPL to include the
<a href="https://smlfamily.github.io/Basis/index.html">SML Basis Library</a>,
which defines important functions such as <code>print</code>.
<br><br>
When we compile a <code>.sml</code> file, MPL implicitly includes the basis
library. But when we use a <code>.mlb</code>, we have to be more explicit.
(This way, our <code>.mlb</code> file
describes <strong>everything</strong> about our program. No hidden pieces!)
</blockquote>
</details>

We can pass the `.mlb` directly to MPL, similar to before.

```console
$ mpl hello-twice.mlb
$ ./hello-twice
hello world
hello again
```
