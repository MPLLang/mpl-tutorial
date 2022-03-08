# MPL Tutorial

## Introduction

[MPL][mpl] is a compiler for parallel programming on shared-memory multicore
machines. The MPL language is essentially [Standard ML][sml] (SML) with
extensions for parallelism.

This tutorial provides an introduction to using MPL. You don't need to
already know SML, but you should be comfortable with using the command-line
shell and know some basic programming (integers, booleans, conditionals,
variables, functions, recursion, etc.).

All source code is contained in this repo. Some of the examples use
primitives from a shared library [lib/](lib/).

## Get started

We recommend that you clone this repository and then run the tutorial
in a [Docker container](https://www.docker.com/) using the top-level Dockerfile:

```
$ git clone https://github.com/MPLLang/mpl-tutorial.git
$ cd mpl-tutorial
$ ./start-container.sh
```
This opens a bash shell in the container. The directory structure inside the
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

More detailed instructions are [here](01-setup/README.md).

## Table of Contents

1. [Setup](01-setup/README.md): running with docker and/or installing the compiler
2. [Hello World](02-hello/README.md): writing, compiling, and running a simple program
3. [Parallelism and Granularity Control](03-how-to-par/README.md): simple parallelism with `ForkJoin.par`, and work-efficiency via granularity control
4. [Trees](04-trees/README.md): parallel algorithms on binary trees, tree
balance experiments

[mpl]: https://github.com/MPLLang/mpl
[sml]: https://en.wikipedia.org/wiki/Standard_ML
