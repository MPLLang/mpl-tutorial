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

## Table of Contents

1. [Setup](01-setup/): installing the compiler
2. [Hello World](02-hello/): writing, compiling, and running a simple program
3. [Parallel Fibonacci](03-fibonacci/): simple parallelism with `par`
4. [Mergesort](04-mergesort/): parallel sequences

[mpl]: https://github.com/MPLLang/mpl
[sml]: https://en.wikipedia.org/wiki/Standard_ML
