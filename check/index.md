# An HTML Validator

## Outline

- Represent HTML as a `Node` inductive: `Text`, `Element` (tag + attrs + children)
- Visitor pattern: `Visitor α` is a record of callbacks invoked as `walk` enters and
  leaves each node; `walk` handles the recursion
- Validator 1: check that `<img>` elements have an `alt` attribute
- Validator 2: check that `<a>` elements have an `href` attribute
- Both validators are built with the same `walk` infrastructure; adding a new check
  is just a new function, not a change to `walk`

## Code

[%inc code.lean %]
