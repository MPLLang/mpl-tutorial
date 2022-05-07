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
* `map` takes a function from elements to (possibly new type of) elements and creates a new sequence by appling the function to each element
* `subseq` takes a sequence and an interval and returns a subsequence that contains the elements in the given interval 
* `append` takes two sequences and appends them
* `filter` takes a boolean function and a sequence and returns a new sequencue consisting of elements that satisfy the function
* `flatten` takes a sequence of sequences and flattens it into a single, flat sequencues by appending the nested sequencues,
* `update` takes an input sequence and a position value pair and returns a new sequence that is identical to the input sequence except at the given position, which contains the specified value
* `inject` takes an input sequence and a sequencue of updates consisting of position-value pairs and returns a new sequence that is idential to the input sequence except and specified updates.  For each updated position, the output sequence contains (an arbitrary) one of the updated values.   
* `isEmpty` returns `true` if the input sequence is empty and `false` otherwise
* `isSingleton` returns `true` if the input sequence is a singleton and `false` otherwise
* `iterate` takes 1) an iterator function, 2) an initial value, 3) and a sequence and iteratively applies the iterator function to the elements of the sequence and previously computed value (or the initial value) and returns the final computed value
* `reduce` takes a 1) associative reducer function that maps to elements to another element, 2) the identity value of the reducer function, and 3) and a sequence and returs the reduced value for the sequence   
* `scan` takes a 1) associative reducer function that maps to elements to another element, 2) the identity value of the reducer function, and 3) and a sequence and returns 1) the reduced value for each prefix of the sequence (starting with the emtpy sequence, for which the value is identity), and 2) the reduced value for the whole sequence    

