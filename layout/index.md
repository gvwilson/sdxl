# Page Layout

## Outline

- Three cell types: `Block` (fixed width × height), `Row` (children side by side),
  `Col` (children stacked)
- Two-pass layout: first compute sizes bottom-up, then assign positions top-down
- `size` recurses over the tree; a `Row`'s width = sum of children widths, height =
  max child height; a `Col`'s height = sum, width = max
- `place` takes a top-left origin and recurses, threading x/y offsets through children
- A `Placed` record pairs each cell with its computed (x, y, w, h)

## Code

[%inc code.lean %]
