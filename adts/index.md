# Algebraic Data Types

## Structures and Inductive Types

-   A `structure` is a product type: every value carries all of its named fields simultaneously
-   Construct a structure with `{ field := value, ... }`; access a field with `s.field`
-   `{ s with field := newVal }` creates a copy with one field changed, leaving the rest untouched
-   `deriving Repr` lets `#eval` print values; `deriving BEq` enables `==`
-   An `inductive` type is a sum type: a value is exactly one of its named constructors
-   Constructors can carry data; a constructor with no arguments behaves like an enum variant
-   `match expr with | Ctor args => body` pattern-matches on a value; Lean rejects incomplete matches at compile time
-   A recursive `inductive` type refers to itself in its own constructors, enabling trees and other nested structures

[%inc code.lean %]

## Exercises

### Traffic Light

-   Define `inductive Light` with constructors `Red`, `Yellow`, and `Green`
-   Write `next : Light → Light` that cycles `Red → Green → Yellow → Red`
-   Verify the full three-step cycle with `#guard`

### Shape Area Extended

-   Add a `Triangle` constructor to the `Shape` type carrying a `base` and `height`
-   Extend the `area` function to handle it and verify with `#guard` that a triangle with base 6.0 and height 4.0 has area 12.0

### Point Distance

-   Define `structure Point where x y : Float`
-   Write `distance : Point → Point → Float` using the Pythagorean theorem (`Float.sqrt`)
-   Verify that the distance between `(0, 0)` and `(3, 4)` is `5.0`

### Tree Depth

-   Using the `Tree` type from the lesson, write `depth : Tree → Nat` that returns the length of the longest path from root to leaf
-   Verify that `Tree.Leaf` has depth `0` and `sample` from the lesson has depth `2`
