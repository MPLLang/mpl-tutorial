# 1: Setup

[(Hello World →)](../02-hello/README.md)

The compiler consists of a single command-line tool called `mpl`.

You can try out the compiler using the docker.

1) Clone the mpl repository
2) Run in terminal
```
$ docker pull shwestrick/mpl
```

This will pull the docker image for mpl

3)Now start shell on your terminal
```
$ docker run -it shwestrick/mpl /bin/bash
```

You will see a bash shell prompt.  There are pre-compiled binaries in the Docker container.  Trying to run some of these is a good point to start.

```
<mpl prompt> #  cd examples
<mpl prompt> #  ./bin/primes @mpl procs 4 --
```

The above command will run the `primes` benchmark with 4 cores (processors).  Depending on the number of cores your computer has, you might reduce this number.  For example, you could start with 1 and increase.

Here is how things look on my two core laptop

```
<mpl prompt> # ./bin/primes @mpl procs 1 --
generating primes up to 100000000
finished in 1.8301s
number of primes 5761455
result [2, 3, 5, 7, 11, 13, 17, ..., 99999989]
<mpl prompt> # ./bin/primes @mpl procs 2 --
./bin/primes @mpl procs 2 --
generating primes up to 100000000
finished in 1.0952s
number of primes 5761455
result [2, 3, 5, 7, 11, 13, 17, ..., 99999989]

```




TODO:
  - Do we install locally or use Docker?
    - For people on mac OS, they'll need to use Docker.

  [Umut: let's assume docker for now. this is what most people will use.
   Later when time permits, it can be extended.
  ]
 
  - Provide both sets of instructions?
    - If using Docker... how? Do we provide a top-level docker-file for this
    repo?
