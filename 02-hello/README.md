# 2. Hello World

[(← Setup)](../01-setup/README.md) [(Parallel Fibonacci →)](../03-fibonacci/README.md)

## Preliminaries

Make sure that you've already done the [setup](../01-setup/README.md). If
you're using Docker to run the tutorial, all commands below should be
run within the container in directory `~/mpl-tutoral/02-hello/`:

```
$ docker run -it mpl-tutorial /bin/bash
...# cd mpl-tutorial/02-hello
...# <enter commands here>
```

## Write it

Our first program is a one-liner: the function `print` takes a string as
argument and writes it to the terminal.
Note that in SML, it is common to call a function without putting parentheses
around its arguments (e.g. `f x` instead of `f(x)`).

[`mpl-tutorial/02-hello/hello.sml`](./hello.sml):
```sml
val _ = print "hello world\n"
```

<details>
<summary><strong>Question</strong>: What does <code>val _ =</code> mean?</summary>
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

To compile this file, pass it to `mpl` at the command-line. This produces
an executable called `hello`. By default, `mpl` names the executable the same
as the source file. We can tell it to use a different name with the
`-output` flag.

```
[mpl-tutorial/02-hello]$ mpl hello.sml
[mpl-tutorial/02-hello]$ ./hello
hello world

[mpl-tutorial/02-hello]$ mpl -output foobar hello.sml
[mpl-tutorial/02-hello]$ ./foobar
hello world
```

## Compiling multiple files as one program

**`.mlb` Files**. Typically, we don't write programs as just a single `.sml`
file. Instead, we write multiple separate files and then compile them together
as one program. To do this with MPL, we need to write an additional file that
describes how to put the files together. This additional file is called an
[ML Basis File](http://mlton.org/MLBasis), and has the extension `.mlb`.

For example, take a look at [hello-twice.mlb](./hello-twice.mlb), which tells
MPL to load three things: the
[SML basis library](https://smlfamily.github.io/Basis/index.html), and two
files: [hello.sml](./hello.sml) followed by
[hello-again.sml](./hello-again.sml).

[`mpl-tutorial/02-hello/hello-twice.mlb`](./hello-twice.mlb):
```sml
$(SML_LIB)/basis/basis.mlb
hello.sml
hello-again.sml
```

<details>
<summary><strong>Question</strong>: What is this <code>$(SML_LIB)/basis/basis.mlb</code> thing? Why do we need to load the SML basis library? </summary>
<blockquote>
<code>$(SML_LIB)</code> is a
<a href="http://www.mlton.org/MLBasisPathMap">path map</a> that points to
where the SML basis library lives on your machine.
<br><br>
The SML basis library defines important functions such as <code>print</code>.
When we compile a <code>.sml</code> file by itself, MPL implicitly includes the
basis library. But when we use a <code>.mlb</code>, we have to be more explicit.
This way, our <code>.mlb</code> file
describes <strong>everything</strong> about our program. No hidden pieces!
</blockquote>
</details>

We can pass an `.mlb` file directly to MPL to produce an executable, similar to
before.

```
[mpl-tutorial/02-hello]$ mpl hello-twice.mlb
[mpl-tutorial/02-hello]$ ./hello-twice
hello world
hello again
```
