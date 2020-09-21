# 1: Setup

[(Hello World →)](../02-hello/README.md)

There are two options:
  1. Run the tutorial in a Docker container. [Instructions below](#option-1-docker)
  2. Install `mpl` locally on x86-64 Linux. [Instructions below](#option-2-local-install)

We recommend that you use Docker.

## Option 1: Docker

Clone this repository and then build and run a
[Docker container](https://www.docker.com/) using the top-level Dockerfile:

```console
$ git clone https://github.com/MPLLang/mpl-tutorial.git
$ cd mpl-tutorial
$ docker build . -t mpl-tutorial
$ docker run -it mpl-tutorial /bin/bash
```

This opens a bash shell in the container. The directory structure inside the
container is

```
~
├── mpl        # the MPLLang/mpl repository
└── tutorial   # this repository
```

In the container, you can double check that `mpl` has already been installed
(your version number may differ):

```console
<container>$ mpl
MLton [mpl] 20200827.140808-gcce156bf3
```

There are also pre-compiled binaries in the `mpl/examples/bin` subdirectory.
Let's try to run one of these.

**Primes example**. In the container, we can run `primes` with 4
processors.

```console
<container>$ mpl/examples/bin/primes @mpl procs 4 --
generating primes up to 100000000
finished in 0.6058s
number of primes 5761455
result [2, 3, 5, 7, 11, 13, 17, ..., 99999989]
```

Depending on the number of cores you computer has, you might want to decrease
this number. The syntax is `<program> @mpl procs <num processors> --`. For
example, we can run on 1 or 2 processors, shown below.

```console
<container>$ mpl/examples/bin/primes @mpl procs 1 --
generating primes up to 100000000
finished in 2.1835s
number of primes 5761455
result [2, 3, 5, 7, 11, 13, 17, ..., 99999989]

<container>$ mpl/examples/bin/primes @mpl procs 2 --
generating primes up to 100000000
finished in 1.1390s
number of primes 5761455
result [2, 3, 5, 7, 11, 13, 17, ..., 99999989]
```

We can see that with 2 processors, the `primes` benchmark takes about 1
second to run. This is about twice as fast as using one processor, which
took about 2 seconds.

**Other examples**. There are quite a few examples in `mpl/examples/bin`
directory. They can all be called in a similar way to `primes`. See
`mpl/examples/README.md` for details.

Here is running mergesort on 1 and 2 processors:
```
<container>$ examples/bin/msort @mpl procs 1 --
./bin/msort @mpl procs 1 --
generating 100000000 random integers
sorting
finished in 27.9411s
result [0, 0, 0, 1, 1, 2, 4, ..., 99999999]

<container>$ examples/bin/msort @mpl procs 2 --
./bin/msort @mpl procs 2 --
generating 100000000 random integers
sorting
finished in 15.1132s
result [0, 0, 0, 1, 1, 2, 4, ..., 99999999]
```

## Option 2: Local Install

If you are on x86-64 Linux, you can...

TODO continue from here
