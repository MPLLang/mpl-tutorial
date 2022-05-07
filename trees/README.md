# 4. Trees

[(← Parallelism and Granularity Control)](../how-to-par/README.md)
[(Sequences →)](../sequences/README.md)

## Preliminaries

Make sure that you've already done the [setup](../01-setup/README.md). If
you're using Docker to run the tutorial, all commands below should be
run within the container in directory `~/mpl-tutoral/04-trees/`:

```
$ cd path/to/mpl-tutorial
$ ./start-container.sh
<container># cd 04-trees
<container># <enter commands here>
```

## Intro

Trees are natural data structures for parallel algorithms because of
their structure: many parallel algorithms can be expressed in terms of
recursive functions evaluated in parallel across the children of a node.

Here we will consider trees which store elements only at their leaves. This
differs from presentations of trees which are intended to be used as BSTs. The
trees here are intended to be used as parallel lists.

## A Datatype For Binary Trees

The following datatype defines a binary tree type. The integer
at internal nodes will be used to store the sizes of subtrees, which is
important both for granularity control as well as various algorithms. We'll
consider the "size" of a tree to be the number of leaves it has; the
implementation of the `size` function is shown below.

```sml
datatype 'a tree =
  Empty
| Leaf of 'a
| Node of int * ('a tree) * ('a tree)
```

<details>
<summary><strong>Question</strong>: I'm new to SML. How do I read this code?</summary>
<blockquote>
We define a new type, <code>'a tree</code>, which has "elements" of type
<code>'a</code>. This thing written <code>'a</code> is a
<em>type parameter</em>. In other languages, like Java
or C++, you might see a similar type written as
<code>Tree&lt;T&gt;</code> where <code>T</code> is the type parameter.
In SML, we write the type parameter on the left
instead of the right, and we don't need to use any brackets or parentheses.
<br><br>
For example, in the code <code>val x: string tree = ...</code>, we have
a variable <code>x</code> of type <code>string tree</code>. Here, the
type parameter <code>'a</code> has been instantiated as <code>string</code>.
<br><br>
There are three possibilities for a thing of type <code>'a tree</code>:
  <ol>
    <li>it could be <code>Empty</code>,</li>
    <li>it could be <code>Leaf x</code>, where <code>x</code> is a value of
    type <code>'a</code>, or</li>
    <li> it could be <code>Node(n,l,r)</code>, where
    <code>n</code> is an integer, and <code>l</code> and <code>r</code> are
    two subtrees, both of type <code>'a tree</code>. In this tutorial, we will
    be using the integer <code>n</code> to keep track of subtree sizes.</li>
  </ol>
<br>
When defining the datatype, we separate the different possibilities with
the symbol <code>|</code>, pronounced "or". Each possibility
is identified by a tag (i.e., <code>Empty</code>, <code>Leaf</code>,
and <code>Node</code>), and then, if desired, the keyword <code>of</code>
followed by a type. This indicates that the tag carries additional data
with it. For example,
<code>Leaf of 'a</code> says the <code>Leaf</code> tag carries a thing of
type <code>'a</code> along with it, but the <code>Empty</code> tag doesn't have
have any additional data.
<br><br>
For the <code>Node</code> case, the extra data has multiple components. Note
the symbol <code>*</code> between each component of the type. This syntax is
more generally used for all
<em>tuples</em> in the language. For example, a function that takes two integers as
argument and returns a string would have type
<code>(int * int) -> string</code>.
<br><br>
In SML, tuples are first-class members of the language. One could think of our
tree <code>Node</code> as containing three pieces of data (an integer and
two subtrees), but it might be more accurate to think of a <code>Node</code> as
containing a <em>single</em> piece of data: a tuple of three components.
</blockquote>
</details>

```sml
fun size t =
  case t of
    Empty => 0
  | Leaf _ => 1
  | Node (n, _, _) => n
```

<details>
<summary><strong>Question</strong>: I'm new to SML. How do I read this code?</summary>
<blockquote>
The only thing we haven't seen before is <code>case ... of ...</code>, which
lets you choose what to do based on what a value looks like. Here, we ask
what <code>t</code> is. If <code>t = Empty</code>, then we do the first
branch, returning 0. If <code>t = Leaf _</code>, then we do the second
branch, returning 1. In the third case, when <code>t = Node(n,_,_)</code>,
we return <code>n</code>, the integer stored at that node (which, recall,
we intend to use to keep track of how many leaves are under that node).
<br><br>
The underscores (<code>_</code>) are used to ignore values that we don't need.
For example, we don't care what is stored at the leaf when we return 1.
<br><br>
In languages like C and Java, you may have seen <code>switch (...) {...}</code>,
which is similar, but in SML you don't have to worry about putting those
pesky <code>break</code>s in the correct places...
</blockquote>
</details>

## Parallel Reduction

Perhaps the simplest parallel algorithm on a tree is `reduce`, which which
takes an associative function `f: ('a * 'a) -> 'a` as argument and
computes the "sum" (with respect to `f`) of the leaves of a tree.
`reduce` also takes an argument `id` which is an
identity element for `f` (i.e. we assume `f(id, x) = f(x, id) = x` for any `x`).
This also serves as a convenient return value for inputs that are `Empty`.

Some interesting use cases, given `t: int tree`:
  * `reduce (fn (a,b) => a+b) 0 t` is the sum of `t`.
  * `reduce (fn (a, b) => a*b) 1 t` is the product of `t`.
  * `reduce Int.max (valOf Int.minInt) t` is the maximum of `t`.
  * `reduce (fn (a, b) => if a >= 0 then a else b) ~1 t` gives you the first
  non-negative value in `t`.
    - Fun exercise: try proving that this function is associative.
    - Also, note that the choice of `~1` as the "identity" element is a little
    bit relaxed. As long as there is at least one non-negative element, it
    won't affect the answer.

The `reduce` function is easy to parallelize, as the two children of every
internal node can be processed in parallel, and finally their results
can be combined with `f`.

Similar to the [previous section](../03-how-to-par/README.md),
we use granularity control to ensure that the cost of `ForkJoin.par` is
amortized. Here, this is implemented by switching to `reduceSeq`
below a size threshold `GRAIN`. The `reduceSeq` function is just a sequential
version of the same algorithm; this will also be useful for experiments later,
to check if our granularity control is working.

```sml
  fun reduceSeq f id t =
    case t of
      Empty => id
    | Leaf x => x
    | Node (_, left, right) => f (reduceSeq f id left, reduceSeq f id right)

  val GRAIN = 5000

  fun reduce f id t =
    if size t < GRAIN then
      reduceSeq f id t
    else
      case t of
        Empty => id
      | Leaf x => x
      | Node (_, left, right) =>
          let
            val (resultLeft, resultRight) =
              ForkJoin.par (fn () => reduce f id left,
                            fn () => reduce f id right)
          in
            f (resultLeft, resultRight)
          end
```

<details>
<summary><strong>Question</strong>: I'm new to SML. How do I read this code?</summary>
<blockquote>
We haven't seen the syntax <code>fun reduce f id t = ...</code> before. This
is called <em>currying</em>. It's a trick in functional languages where you can
pass multiple arguments without using a tuple.
<br><br>
The syntax <code>fun reduce f id t = ...</code> is shorthand for
<code>val reduce = (fn f => (fn id => (fn t => ...)))</code>, i.e.,
<code>reduce</code> is a function that returns a function which returns a
function, etc. This might seem crazy, but it can actually be very convenient
in some cases.
<br><br>
For example, we could write
<code>val sum = reduce (fn (a,b) => a+b) 0</code>. Notice that we left out the
last argument to <code>reduce</code>, so therefore <code>sum</code> is a
function which is "waiting to receive the last argument".
This is equivalent to writing
<code>fun sum t = reduce (fn (a,b) => a+b) 0 t</code>.
<br><br>
You might be wondering: isn't that really inefficient? The short answer is
no; it's just as efficient as using tuples to pass arguments. The long answer
gets into some pretty low-level details about how compilers work.
<br><br>
To learn more, we recommend reading more about currying online:
  <ul>
    <li><a href="https://en.wikipedia.org/wiki/Currying">Wikipedia entry</a></li>
  </ul>
</blockquote>
</details>

## A Balancing Act: Trees To Test With

Consider the following two functions, `makeUnbalanced` and
`makeBalanced`. Both functions take two integers `i` and `n` as
argument, and return a tree of size `n` whose leaves (in order) are
`f(i)`, `f(i+1)`, ..., `f(i+n-1)`. The two functions differ in the
structure of the tree produced. This will be helpful for testing performance,
below.

The function `makeUnbalanced` builds a tree that
leans hard to the right, with final height exactly `n`. In contrast, the
function `makeBalanced` builds a tree that is almost perfectly balanced, with
final height approximately `log(n)`.

To help highlight the similarities between these two functions, we have not
parallelized either one. It's worth mentioning however that, while
`makeBalanced` could easily be parallelized, the function `makeUnbalanced` has
essentially no opportunity for parallelism.

```sml
  fun makeUnbalanced f i n =
    case n of
      0 => Empty
    | 1 => Leaf (f i)
    | _ =>
        let
          val l = Leaf (f i)
          val r = makeUnbalanced f (i+1) (n-1)
        in
          Node (n, l, r)
        end


  fun makeBalanced f i n =
    case n of
      0 => Empty
    | 1 => Leaf (f i)
    | _ =>
        let
          val half = n div 2
          val l = makeBalanced f i half
          val r = makeBalanced f (i + half) (n - half)
        in
          Node (n, l, r)
        end
```

## Balanced vs Unbalanced Performance

Here we'll measure the performance `reduce` by summing trees of different
structure. We define two functions, `sum` and `sumSeq`, and two test trees,
`balancedTree` and `unbalancedTree`.
Both trees have 100K leaves, but while `balancedTree` has height only 18,
`unbalancedTree` has height 100K.

```sml
fun sumSeq tree = Tree.reduceSeq (fn (a, b) => a+b) 0 tree
fun sum tree = Tree.reduce (fn (a, b) => a+b) 0 tree

val size = 100000
val balancedTree = Tree.makeBalanced Int64.fromInt 0 size
val unbalancedTree = Tree.makeUnbalanced Int64.fromInt 0 size
```

In `test-balanced/` and `test-unbalanced/`, we've set up two benchmarks
which take multiple time measurements and report the average.

### Balanced Tree Performance
First, let's measure the performance of summing the balanced tree, which has
100K leaves and height 18. We run both sequential and parallel versions, first
using only one processor, and then using 4 processors.

Notice that on 1 processor, the parallel version has nearly identical
performance as the sequential code, confirming that our granularity control
is working. On 4 processors, we get about 2.5x speedup. Not bad, especially
for such a small problem size.

```
<container># mpl test-balanced/main.mlb

<container># test-balanced/main
size 100000
built balancedTree: height 18
============ sequential ============
warmup...... timing...
sumSeq(balancedTree) time: 0.0020s
============= parallel =============
warmup...... timing...
sum(balancedTree) time: 0.0021s       # uniprocessor time
                                      # approx the same as sequential
                                      # (good!)

<container># test-balanced/main @mpl procs 4 --
size 100000
built balancedTree: height 18
============ sequential ============
warmup...... timing...
sumSeq(balancedTree) time: 0.0019s
============= parallel =============
warmup...... timing...
sum(balancedTree) time: 0.0008s       # parallel time on 4 processors
                                      # approx 2.4x faster than sequential
                                      # (nice!)
```

### Unbalanced Tree Performance
In contrast, the unbalanced tree (100K leaves, 100K height) does not do so
well. The parallel version on a single processor is 66x slower than sequential:

```
<container># mpl test-unbalanced/main.mlb

<container># test-unbalanced/main
size 100000
built unbalancedTree: height 100000
============ sequential ============
warmup...... timing...
sumSeq(unbalancedTree) time: 0.0008s
============= parallel =============
warmup...... timing......
sum(unbalancedTree) time: 0.0528s    # uniprocessor time
                                     # 66x slower than sequential!
```

**Why is it so much slower?** In this case, because of poor granularity control.
Recall that our granularity control in `reduce` uses a fast sequential algorithm
below the grain size, `GRAIN`, with the idea that this should significantly
reduce the number of calls to `ForkJoin.par` and therefore amortize their cost.
However, this approach is only effective for balanced trees.

Consider that the
number of calls to `ForkJoin.par` is determined by how many internal nodes
of the tree have size larger than the grain size, `GRAIN`.
**On the balanced tree**, there are approximately `n / GRAIN` internal nodes
with size larger than the grain size, and therefore only about `n / GRAIN`
calls to `ForkJoin.par`.
**But on the unbalanced tree**, there are as many as `n - GRAIN` internal
nodes! As a result, the cost of `ForkJoin.par` has not been effectively
amortized.

### Ensuring Balance

To ensure balance, we could easily adapt the trees here to be self-balancing
via any number of schemes:
[AVL](https://en.wikipedia.org/wiki/AVL_tree),
[red-black](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree),
[weight-balanced](https://en.wikipedia.org/wiki/Weight-balanced_tree),
[treaps](https://en.wikipedia.org/wiki/Treap),
etc.
Because we already store the sizes of subtrees at internal nodes (which is
useful for other purposes, including granularity control), it would be
especially easy to adapt the trees here to be weight-balanced.

In a [recent paper](https://www.cs.cmu.edu/~guyb/papers/BFS16.pdf),
Guy Blelloch, Daniel Ferizovic, and Yihan Sun showed that to implement almost
any balancing scheme, you only need a single primitive called `join` which
stitches two (balanced) trees together, producing a similarly balanced tree.
All other operations which construct trees can then be implemented in terms of
`join`, with optimal performance in theory, and excellent practical performance
as well, including in parallel.

In terms of code. this approach is especially simple: any time we would
construct a `Node` from two trees `t1` and `t2`, we instead just call
`join (t1, t2)`. This then ensures that all trees we build are balanced.

## Scan (Parallel Prefix Sums)

The `scan` primitive is one of the most fundamental operations in parallel
computing. Similar to `reduce`, the goal is to compute a "sum" with respect to
some arbitrary associative function; the difference with `scan` is that we
additionally want the sums of every prefix. `scan` returns a tuple of a
tree containing all prefix sums, and the total sum.

Sequentially, `scan` can be accomplished with an in-order traversal and an
"accumulator" which we use to keep track of the running sum.[^1] This is the
variable `acc: 'a` in the following code.

```sml
  (** A recursive loop to compute scan. *)
  fun scanLoop (f: 'a * 'a -> 'a) (acc: 'a) (t: 'a tree) : 'a tree * 'a =
    case t of
      Empty => (Empty, acc)
    | Leaf x => (Leaf acc, f (acc, x))
    | Node (n, left, right) =>
        let
          val (leftPrefixSums, accLeft) = scanLoop f acc left
          val (rightPrefixSums, accRight) = scanLoop f accLeft right
          val allSums = Node (n, leftPrefixSums, rightPrefixSums)
        in
          (allSums, accRight)
        end

  (** Sequential scan is just a call to the helper loop. *)
  fun scanSeq f id t =
    scanLoop f id t
```

The parallel algorithm for scan we will implement here is the
"upsweep-downsweep" scan, which consists of two phases:
  1. *Upsweep*: we compute a reduce, but build a tree which saves all
  intermediate results. Specifically, at each internal node, we remember
  the reduced (summed) value of all leaves under that node.
  2. *Downsweep*: using the result of the upsweep, we push prefix sums down
  into the original tree. This is accomplished by keeping track of a variable
  `acc` which is the total sum of everything to the left. When we move down to
  a left child, we keep the same `acc`. When we move down to a right child,
  we use the stored value in the upswept tree to adjust the `acc` appropriately.

For the upsweep, we define a new datatype which will be used only in the
implementation of `scan`. The datatype is called `sum_tree`, and it has
two cases: `GrainSum` (to store the result of the reduce below the grain size)
and `NodeSum` (to store the result of the reduce when the two children are
computed in parallel).

```sml
datatype 'a sum_tree =
  GrainSum of 'a
| NodeSum of 'a * 'a sum_tree * 'a sum_tree

fun sumOf (st: 'a sum_tree) : 'a =
  case st of
    GrainSum x => x
  | NodeSum (x, _, _) => x
```

TODO continue from here...
