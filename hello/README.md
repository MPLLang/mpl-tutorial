# 2. Hello World

[(← Setup)](../setup/README.md) [(Parallelism and Granularity Control →)](../how-to-par/README.md)

## Preliminaries

Make sure that you've already done the [setup](../01-setup/README.md). If
you're using Docker to run the tutorial, all commands below should be
run within the container in directory `~/mpl-tutoral/02-hello/`:

```
$ cd path/to/mpl-tutorial
$ ./start-container.sh
<container># cd 02-hello
<container># <enter commands here>
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
variable. For example, <code>val x = 2+2</code>.

But in this case, <code>print</code> doesn't return anything interesting, so we
just write <code>val _ = print ...</code> which means "print the thing, but
don't introduce a new variable for the result".
</blockquote>
</details>

## Compile and run it

To compile this file, pass it to `mpl` at the command-line. This produces
an executable called `hello`. By default, `mpl` names the executable the same
as the source file. We can tell it to use a different name with the
`-output` flag.

```
<container># ls
README.md  hello-again.sml  hello-twice.mlb  hello.sml

<container># mpl hello.sml
<container># ./hello
hello world

<container># mpl -output foobar hello.sml
<container># ./foobar
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

We can pass an `.mlb` file directly to MPL to produce an executable, similar to
before.

```
<container># mpl hello-twice.mlb
<container># ./hello-twice
hello world
hello again
```

<details>
<summary><strong>Question</strong>: What is this <code>$(SML_LIB)/basis/basis.mlb</code> thing? </summary>
<blockquote>
This loads the
<a href="https://smlfamily.github.io/Basis/">SML basis library</a>, which is
the standard library included in all SML distributions. It includes the
definition of important functions such as <code>print</code>.
<br><br>
When we compile a <code>.sml</code> file by itself, the basis library is
implicitly included for convenience. But when we use a <code>.mlb</code>, we
have to be more explicit. This way, our <code>.mlb</code> file
describes <strong>everything</strong> about our program. No hidden pieces!
</blockquote>
</details>
