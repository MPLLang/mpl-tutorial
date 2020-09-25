structure Seq:
sig
  type 'a t
  type 'a seq = 'a t

  val nth: 'a seq -> int -> 'a
  val length: 'a seq -> int

  val empty: unit -> 'a seq
  val tabulate: int * (int -> 'a) -> 'a seq
  val append: 'a seq * 'a seq -> 'a seq

  val subseq: 'a seq -> int * int -> 'a seq
  val take: 'a seq -> int -> 'a seq
  val drop: 'a seq -> int -> 'a seq

  val filter: ('a -> bool) -> 'a seq -> 'a seq
  val map: ('a -> 'b) -> 'a seq -> 'b seq
  val reduce: ('a * 'a -> 'a) -> 'a -> 'a seq -> 'a
  val scan: ('a * 'a -> 'a) -> 'a -> 'a seq -> 'a seq

  val merge: ('a * 'a -> order) -> 'a seq * 'a seq -> 'a seq
end =
struct
  type 'a t = 'a ArraySlice.slice
  type 'a seq = 'a t

  structure A = Array
  structure AS = ArraySlice

  val parfor = ForkJoin.parfor
  val par = ForkJoin.par
  val alloc = ForkJoin.alloc

  val gran = 5000

  fun nth s i =
    AS.sub (s, i)

  fun length s =
    AS.length s

  fun empty () =
    AS.full (Array.fromList [])

  fun subseq s (i, len) =
    AS.subslice (s, i, SOME len)

  fun take s i =
    subseq s (0, i)

  fun drop s i =
    subseq s (i, length s - i)

  fun tabulate (n, f) =
    AS.full (SeqBasis.tabulate gran (0, n) f)

  fun append (s, t) =
    AS.full (SeqBasis.tabulate gran (0, length s + length t) (fn i =>
      if i < length s then
        nth s i
      else
        nth t (i - length s)
    ))

  fun map f s =
    AS.full (SeqBasis.tabulate gran (0, length s) (f o nth s))

  fun reduce f b s =
    SeqBasis.reduce gran f b (0, length s) (nth s)

  fun scan f b s =
    AS.full (SeqBasis.scan gran f b (0, length s) (nth s))

  fun filter p s =
    AS.full (SeqBasis.filter gran (0, length s) (nth s) (p o nth s))

  fun merge cmp (s, t) =
    AS.full (SeqBasis.merge gran cmp (0, length s, nth s) (0, length t, nth t))
end
