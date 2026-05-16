# A Template Expander

## Outline

- Templates are `TNode` trees: `TText` (literal), `TVar` (variable lookup),
  `TLoop` (repeat over a list), `TIf` (conditional), `TSeq` (sequence of nodes)
- A `Context` maps variable names to `TVal` (string or list of contexts)
- `expand` recurses over the tree, threading the context through
- `TLoop` evaluates its body once for each item in a list variable, pushing a new
  context frame per iteration
- No file I/O needed to show the core design; the IO wrapper just reads a template
  from a file and writes the rendered output

## Code

[%inc code.lean %]
