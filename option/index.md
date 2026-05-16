# The Option Type

## Handling Missing Values

-   `Option α` represents a value that may be absent: `some v` wraps a present value and `none` signals absence
-   This is Lean's answer to `null`; the type system forces every caller to handle both cases explicitly
-   Pattern match with `| some v => ... | none => ...` when the two branches need different logic
-   `Option.map f opt` applies `f` to the wrapped value if present; `none` passes through unchanged
-   `Option.getD opt default` extracts the value or returns `default` when the option is `none`
-   `do` notation for `Option` lets you sequence option-returning steps; a single `none` short-circuits the rest of the chain

[%inc missing.lean %]

## Lists and Option

-   `List.find? p xs` returns `some x` for the first element satisfying `p`, or `none` if nothing matches
-   `List.filterMap f xs` applies `f` to each element and collects only the `some` results
-   `List.findSome? f xs` applies `f` and returns the first `some` result, stopping early
-   The shorthand `(·.1 == key)` reads as `fun p => p.1 == key`, useful for searching lists of pairs
-   Combine `find?` and `map` to implement safe dictionary lookup over `List (String × α)` without any special data structure

[%inc listops.lean %]

## Exercises

### Safe Head

-   Write `safeHead : List α → Option α` that returns the first element or `none` for an empty list
-   Verify it on both an empty list and a non-empty list using `#guard`

### Chain of Divisions

-   Using `do` notation, divide 120 by three separate inputs in sequence
-   Return `none` if any divisor is zero, or `some` of the final quotient otherwise
-   Verify three cases: all non-zero, first divisor zero, third divisor zero

### Lookup with Default

-   Given `scores : List (String × Nat)`, write a function that returns the score for a name formatted as a string
-   Return `"not found"` when the name is absent

### Parse Rows

-   Given a list of strings in `"name,score"` format, use `filterMap` and `String.splitOn` to extract valid `(String × Nat)` pairs
-   Skip any string that does not contain exactly one comma or whose score is not a valid number
-   Use `String.toNat?` for parsing

### All Present

-   Write `allPresent : List (Option α) → Option (List α)` that returns `some` of the unwrapped list if every element is `some`, or `none` if any element is `none`
-   Verify on `[some 1, some 2, some 3]` and `[some 1, none, some 3]`
