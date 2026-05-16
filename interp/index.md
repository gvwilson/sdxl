# An Interpreter

## Outline

- Represent programs as `Expr` inductive trees: `Num`, `Add`, `Sub`, `Mul`, `Neg`,
  `Abs`, `Var`
- An `Env` maps variable names to integer values
- `eval` pattern-matches on the node type and dispatches to the appropriate operation
- Undefined variables return `none`; all operations propagate `none` (using `Option`)
- Extend by adding new `Expr` constructors and `eval` cases — no existing code changes

## Code

[%inc code.lean %]
