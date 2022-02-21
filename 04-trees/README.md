# 4. Trees

[(← Parallelism and Granularity Control)](../03-how-to-par/README.md)

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
<br><br>
For the <code>Node</code> case, note that we use asterisks (<code>*</code>) to
separate components of the type. This syntax is more generally used for all
tuples in the language. For example, a function that takes two integers as
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
TODO...
</blockquote>
</details>

## Parallel Reduction

Perhaps the simplest parallel algorithm on a tree is `reduce`, which which
takes an associative function `f: ('a * 'a) -> 'a` as argument and
computes the "sum" (with respect to `f`) of the leaves of a tree.
Note that the function additionally takes an argument `id` which is an
identity element for `f`. (In particular, we assume `f(id, x) = x` for any `x`.)
This also serves as a convenient return value for inputs that are `Empty`.

The `reduce` function is easy to parallelize, as the two children of every
internal node can be processed in parallel, and finally their results
can be combined with `f`.

Similar to the [previous section](../03-how-to-par/README.md),
we use granularity control to ensure that the cost of `ForkJoin.par` is
properly amortized. Here, this is implemented by switching to `reduceSeq`
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
TODO...
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

<details>
<summary><strong>Question</strong>: I'm new to SML. How do I read this code?</summary>
<blockquote>
TODO...
</blockquote>
</details>

## Performance Testing

Here we'll measure the performance `reduce` by summing trees of different
structure.

TODO continue here...
