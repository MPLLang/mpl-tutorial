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
consider the "size" of a tree to be the number of leaves it has.

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

## A Balancing Act

Our trees are very flexible. The datatype above imposes no restrictions on the
heights of subtrees. However, it would be nice to ensure that trees are
*balanced*, i.e., that for each `Node`, both children are approximately the same
height (or approximately the same size). This will make it easy to parallelize
algorithms on trees.

When building a tree from scratch, it's easy to ensure that the result is
balanced. For example, consider the following function, `makeBalanced f n`,
which (in parallel) builds a balanced tree of size `n` with leaf elements
`f(0)`, `f(1)`, etc. The resulting tree has height approximately `log(n)`.

```sml
  fun makeBalanced f n =
    let
      (** recursive helper computes the subtree with leaf elements
        * f(offset), f(offset+1), ..., f(offset+size-1)
        *)
      fun subtree offset size =
        case size of
          0 => Empty
        | 1 => Leaf (f offset)
        | _ =>
            let
              (** divide approximately in half, such that
                * size = leftSize + rightSize *)
              val leftSize = size div 2
              val rightSize = size - leftSize

              fun left () = subtree offset leftSize
              fun right () = subtree (offset+leftSize) rightSize

              val (l, r) =
                (* granularity control *)
                if size < GRAIN then
                  (left (), right ())
                else
                  ForkJoin.par (left, right)
            in
              Node (size, l, r)
            end
    in
      subtree 0 size
    end
```

<details>
<summary><strong>Question</strong>: I'm new to SML. How do I read this code?</summary>
<blockquote>
TODO...
</blockquote>
</details>

## Interface

Here's the interface we're shooting for:

```sml
val tabulate: (int -> 'a) -> int -> 'a tree
val map: ('a -> 'b) -> 'a tree -> 'b tree
val filter: ('a -> bool) -> 'a tree -> 'a tree
val reduce: ('a * 'a -> 'a) -> 'a -> 'a tree -> 'a
```

## Sequential First

Before attempting to exploit parallelism, it's important to consider first how
you might solve a problem without parallelism.
