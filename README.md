# MPL Tutorial

## Introduction

[MPL][mpl] is a compiler for parallel programming on shared-memory multicore
machines. The MPL language is essentially [Standard ML][sml] (SML) with
extensions for parallelism.

This tutorial provides an introduction to using MPL. You don't need to
already know SML, but you should be comfortable with using the command-line
shell and know some basic programming (integers, booleans, conditionals,
variables, functions, recursion, etc.).

All source code is contained in this repo. Some of the examples use the
[`mpllib`](https://github.com/MPLLang/mpllib).

## Get started

(**Note**: more detailed instructions available [here](01-setup/README.md)).

We recommend that you clone this repository and then run the tutorial
in a [Docker container](https://www.docker.com/) using the top-level Dockerfile.

```
$ git clone https://github.com/MPLLang/mpl-tutorial.git
$ cd mpl-tutorial
$ ./start-container.sh
```

This opens a bash shell in the container, which should have a prompt that
looks something like this (the numbers after `root@` may differ; this is
normal):
```
root@b80fc75d8c76:~/mpl-tutorial#
```

For simplicity throughout the tutorial, we will write `<container>#` before
commands that are intended to be run inside the Docker container.

### Inside the container

The directory structure inside the
container is as follows. Starting the container puts us inside the
`mpl-tutorial` directory.

```
root
├── mpl            # the MPLLang/mpl repository
└── mpl-tutorial   # this repository
```

Inside the container, the directory `mpl-tutorial` is mounted from your local
machine. Any changes within this directory will be visible both inside
and outside the container. This ensure that any changes you make will not be
lost when you exit the container, and also allows you to use any text editor
outside the container to edit files.

### Pull the library

Once you have started the container, you need to pull the library code:

```
<container># pwd
/root/mpl-tutorial
<container># smlpkg sync
```

This populates the directory `lib` with packages that this tutorial depends
on. You only need to do this once, when starting the tutorial for the first
time.

Do not modify the contents of the `lib` subdirectory. These are maintained
by the package manager.

## Table of Contents

1. [Setup](01-setup/README.md): running with docker and/or installing the compiler
2. [Hello World](02-hello/README.md): writing, compiling, and running a simple program
3. [Parallelism and Granularity Control](03-how-to-par/README.md): simple parallelism with `ForkJoin.par`, and work-efficiency via granularity control
4. [Trees](04-trees/README.md): parallel algorithms on binary trees, tree
balance experiments

[mpl]: https://github.com/MPLLang/mpl
[sml]: https://en.wikipedia.org/wiki/Standard_ML

## FAQ

**Help: Inside the Docker container, a process dies with the message `Killed`**.
This is likely due to a Docker memory limit. See the *Docker Resource Limits*
section of [Setup](01-setup/README.md) for instructions on how to fix.

**Help: When compiling, I see a long string of errors such as `Undefined structure`**.
Make sure you've pulled the library code. See the *Pull the library* section,
above.
