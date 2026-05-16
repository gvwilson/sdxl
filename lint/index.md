# A Code Linter

## Outline

- Define a simplified `Stmt` AST: `Assign`, `If`, `While`, `Block`, `Dict` (literal),
  `Call`
- Visitor pattern: a record of per-node handlers; `walk` dispatches to the right one
  and recurses
- Linter 1: find duplicate keys in dictionary literals by collecting all `Dict` nodes
- Linter 2: find variables assigned but never used in a block
- Each linter is a separate function over the same `walk` infrastructure — open for
  extension, closed for modification

## Code

[%inc code.lean %]
