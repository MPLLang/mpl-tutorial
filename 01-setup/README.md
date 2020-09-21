# 1: Setup

[(Hello World →)](../02-hello/README.md)

We recommend that you use [Docker](https://www.docker.com/) to run this
tutorial. Instructions are below. If you're on Linux, you can also install
`mpl` locally; these instructions are in the top-level README.md of
the [mpl repository](https://github.com/MPLLang/mpl).

## MPL Docker Image and Examples

Begin by pulling the docker image for `mpl` and running it with a shell.

```
$ docker pull shwestrick/mpl                # download the image
$ docker run -it shwestrick/mpl /bin/bash   # start shell in a container
```

You are now in the container, with a shell prompt at the root of
the [mpl repository](https://github.com/MPLLang/mpl). Inside the container,
the `mpl` has already been installed. There are also pre-compiled
binaries in the `examples/bin` subdirectory. Let's try to run one of these.

**Primes example**. In the container, we can run `primes` with 4
processors.

```
<mpl prompt># examples/bin/primes @mpl procs 4 --
generating primes up to 100000000
finished in 0.6058s
number of primes 5761455
result [2, 3, 5, 7, 11, 13, 17, ..., 99999989]
```

Depending on the number of cores you computer has, you might want to decrease
this number. The syntax is `<program> @mpl procs <num processors> --`. For
example, we can run on 1 or 2 processors, shown below.

```
<mpl prompt># examples/bin/primes @mpl procs 1 --
generating primes up to 100000000
finished in 2.1835s
number of primes 5761455
result [2, 3, 5, 7, 11, 13, 17, ..., 99999989]

<mpl prompt># examples/bin/primes @mpl procs 2 --
generating primes up to 100000000
finished in 1.1390s
number of primes 5761455
result [2, 3, 5, 7, 11, 13, 17, ..., 99999989]
```

We can see that with 2 processors, the `primes` benchmark takes about 1
second to run. This is about twice as fast as using one processor, which
took about 2 seconds.

**Other examples**. There are quite a few examples in `examples/bin` directory.
They can all be called in a similar way to `primes`. See
`examples/README.md` for details.

Here is running mergesort on 1 and 2 processors:
```
<mpl prompt># examples/bin/msort @mpl procs 1 --
./bin/msort @mpl procs 1 --
generating 100000000 random integers
sorting
finished in 27.9411s
result [0, 0, 0, 1, 1, 2, 4, ..., 99999999]

<mpl prompt># examples/bin/msort @mpl procs 2 --
./bin/msort @mpl procs 2 --
generating 100000000 random integers
sorting
finished in 15.1132s
result [0, 0, 0, 1, 1, 2, 4, ..., 99999999]
```

## Running this tutorial in Docker

To run this tutorial, use the [top-level Dockerfile](../Dockerfile) in this
repository.

```console
$ git clone https://github.com/MPLLang/mpl-tutorial.git
$ cd mpl-tutorial
$ docker build . -t mpl-tutorial
$ docker run -it mpl-tutorial /bin/bash
```

This starts a container with the following directory structure.

```
~
├── mpl            # the MPLLang/mpl repository
└── mpl-tutorial   # this repository
```
