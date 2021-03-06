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
$ docker build . -t mpl-tutorial
$ docker run -it mpl-tutorial /bin/bash
```
This opens a bash shell in the container. The directory structure inside the
container is:

```
~
├── mpl            # the MPLLang/mpl repository
└── mpl-tutorial   # this repository
```


If you will be actively writing code in a directory say called <local-dir> and running it from within the docker container, then you want mount your local directory to the container like this
```
docker run -v <local-dir>:/mnt/<local-dir> -it mpl-tutorial /bin/bash
```
With this command, the directory `/mnt/local-dir` will contain your local directory.

More detailed instructions are [here](01-setup/README.md).

## Table of Contents

1. [Setup](01-setup/README.md): running with docker and/or installing the compiler
2. [Hello World](02-hello/README.md): writing, compiling, and running a simple program
3. [Parallel Fibonacci](03-fibonacci/README.md): simple parallelism with `par`
4. [Mergesort](04-mergesort/README.md): parallel sequences

[mpl]: https://github.com/MPLLang/mpl
[sml]: https://en.wikipedia.org/wiki/Standard_ML
