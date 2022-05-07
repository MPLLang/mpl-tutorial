[(← Trees)](../trees/README.md)
[(MCSS →)](../mcss/README.md)

# Sequences

A sequence 
`<a_0, a_2, ..., a_n>`
is an ordered collection of elements that support several operations, inclduing fast random access.

# Sequence Interface

Sequences support the following operations

* `length` returns the length of the sequence

* `nth` returns the element at the specified position (counting from 0)

* `empty` returns an empty sequence

* `singleton` takes an element and returns a sequence that contains that element (only)

* `tabulate` takes 1) a generator function that takes a position and generates the element at that position 2) a length and returns a sequence of the given length where the element at a given position is computed by appling the generator function (at that position)

* `rev` reverses the given sequence

* `append` takes two sequences and appends them

* `apply` takes a function and a sequence, and applies the function to each element in the input sequence. 

* `applyi` takes a function and a sequence, and applies the function to each position and the element at that position.  It differs from `apply` in that it passes the element position as an argument to the function. 

* `map` takes a function from elements to (possibly new type of) elements and creates a new sequence by appling the function to each element

* `subseq` takes a sequence and an interval and returns a subsequence that contains the elements in the given interval 



* `filter` takes a boolean function and a sequence and returns a new sequencue consisting of elements that satisfy the function

* `flatten` takes a sequence of sequences and flattens it into a single, flat sequencues by appending the nested sequencues,

* `update` takes an input sequence and a position value pair and returns a new sequence that is identical to the input sequence except at the given position, which contains the specified value.  The `update` function is pure is the sense that it does not modify the input sequence.

* `inject` takes an input sequence and a sequencue of updates consisting of position-value pairs and returns a new sequence that is idential to the input sequence except and specified updates.  For each updated position, the output sequence contains (an arbitrary) one of the updated values.   The `inject` function is pure is the sense that it does not modify the input sequence.

* `isEmpty` returns `true` if the input sequence is empty and `false` otherwise

* `isSingleton` returns `true` if the input sequence is a singleton and `false` otherwise

* `iterate` takes 1) an iterator function, 2) an initial value, 3) and a sequence and iteratively applies the iterator function to the elements of the sequence and previously computed value (or the initial value) and returns the final computed value

* `reduce` takes a 1) associative reducer function that maps to elements to another element, 2) the identity value of the reducer function, and 3) and a sequence and returs the reduced value for the sequence   

* `scan` takes a 1) associative reducer function that maps to elements to another element, 2) the identity value of the reducer function, and 3) and a sequence and returns 1) the reduced value for each prefix of the sequence (starting with the emtpy sequence, for which the value is identity), and 2) the reduced value for the whole sequence    

## Implementation

We can implement the sequence interface described above in a number of
ways.  For example, we can use weight-balanced trees to represent the
elements in the sequence.  Such an implementation has the advantage of
allowing us to update an element of the sequence in logarithmic work
but most other operations such as simple accesses also require
logarithmic work.  To provide for constant-work access we can use
arrays.  This comes at the cost of increasing the cost of updates to
linear but this can be avoided in most cases, either by allowing for
destructive updates or by using persistence (versioning).  

## Array Sequences

We implement sequences by using arrays as the backing data structure.
More specificially, we represent a sequence as an array slice, which
is an array with a beginning and ending position.

* Function `nth` simply accesses the element at the specified position
  in the underlying slice.

* Function `subseq` returns the specified subslice of the underlying slice. 

* Function `tabulate` allocates an array of size `n` and populates it by using a parallel for that ranges over all positions in the array.

* Function `rev` reverses the given sequence by applying a `tabulate` 

* Function `append` takes two sequences and appends them by using `tabulate`

* Funciton `map` tabulates a new sequence by using the provided map function on the input sequence.

* Functions `apply` and `applyi` aplies the given function for each
  position in the given array. The difference between `apply` and `applyi` is that `applyi` passes the position as argument to the update function.  Both are implemented as a simple parallel-for loop over the sequence.

* Function `update` takes an input sequence and a position value pair. It first creates a result sequence by copying the input sequence using a `map` and then updates the result sequence at the specified position with the given value.

* Function `inject` takes a sequence and an updat sequence consisting
  of index-value pairs, indicating the position and the value of the
  update respectively.  It then creates a result array by first copying the
  input array and then applying each update in parallel.

* Function `reduce` computes a reduction over the sequence (with the given reducer function) by dividing the input sequence into two halves, recursively reducing each half, and computing the result by applying the reducer to the result from the two halves.

* Function `scanGen` computes `reduce` for all prefixes of the input sequence, including the empty and the full prefix.

* Functions `scan` and `iscan` simply call `scanGen` and return the relevant subsequence of the full prefix reductions.

* Function `filter` first computes an indicator sequence consisting of
  `0` and `1` entries that indicate whether the element at the
  corresponding position is to be excluded from the output or not (`0`
  means exclude, `1` means include).  It then computes the offset for each included element by performing a scan, which also returns the total. Using the total, it allocates a result array and uses `applyi` to populate the result array by copying the included elements to their respective positions.  

* Function `flatten` takes a sequence of sequences and flattens it as
  a single "flat" sequence.  To this end, it first computes a "length
  sequence" consisting of the length of each nested sequence by
  mapping `length` over the sequence.  It then performs a scan over
  the length sequence to compute the `offsets` for each nested
  sequence in the result flat sequence.  Finally, it allocates the result array and copies each nested sequence by using a doubly nested loop over.


