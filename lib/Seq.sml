structure Seq =
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

  fun map f s =
    AS.full (SeqBasis.tabulate gran (0, length s) (f o nth s))

  fun reduce f b s =
    SeqBasis.reduce gran f b (0, length s) (nth s)

  fun scan f b s =
    SeqBasis.scan gran f b (0, length s) (nth s)

  fun filter p s =
    SeqBasis.filter gran (0, length s) (nth s) (p o nth s)

  fun merge cmp (s, t) =
    SeqBasis.merge gran cmp (0, length s, nth s) (0, length t, nth t)
end
