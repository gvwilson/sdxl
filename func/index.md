# Functions and Closures

## Outline

- Extend the `interp` expression tree with `Func` (parameter list + body) and `Call`
- A `Value` is either an `Int` or a `Closure` (parameter list + body + captured env)
- Defining a function creates a `Closure` that captures the current environment
- Calling a function pushes a new frame: bind arguments into a fresh env that extends
  the closure's captured env
- Each call frame is independent; variables do not leak between calls

## Code

[%inc code.lean %]
