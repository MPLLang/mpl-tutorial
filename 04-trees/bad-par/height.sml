fun height t =
  case t of 
    Leaf => 0
  | Node (l, r) =>
    let (hl, hr) = (height l, height r) in
      if hl > hr then 1 + hl else 1 + hr

