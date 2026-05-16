# Values, Types, and Functions

## Types and Values

-   Every value in Lean has a type; `: T` annotates a type explicitly, and the compiler rejects mismatches before the program runs
-   `def` introduces a named definition; `#eval` prints its value at compile time
-   Basic scalar types: `Int` (signed integers), `Nat` (non-negative integers), `Bool`, `String`, `Float`
-   `#guard` checks a boolean expression at compile time; a failing guard is a build error, not a runtime crash
-   `let` binds a local name inside a function body; the binding is immutable, like a variable in an equation
-   `abbrev` creates a transparent alias for an existing type without introducing a new one
-   String interpolation `s!"text {expr}"` converts any value to text without an explicit conversion call

[%inc types.lean %]

## Lists and Lambdas

-   `List α` holds a sequence of values of the same type; write `[a, b, c]` for a literal
-   `List.map f xs` applies `f` to every element and collects the results in a new list
-   `List.filter p xs` keeps only the elements for which predicate `p` returns `true`
-   `List.foldl f init xs` threads an accumulator through the list from left to right
-   Lambda functions are written `fun x => body`; use `·` as a placeholder for simple cases: `(· * 2)` means `fun x => x * 2`
-   Tuple types are written `α × β`; construct with `(a, b)` and access elements with `.1` and `.2`
-   `List (String × Nat)` is the standard pattern for key-value data without importing a map library

[%inc lists.lean %]

## Exercises

### Celsius to Fahrenheit

-   Write `celsiusToFahrenheit : Float → Float` using the formula `(c * 9.0 / 5.0) + 32.0`
-   Use `#guard` to verify that 0 degrees converts to 32.0 and 100 degrees converts to 212.0

### Word Lengths

-   Given a `List String`, use `map` to produce a `List Nat` containing the length of each word
-   Use `String.length` to measure a string

### Running Total

-   Use `foldl` and a lambda to compute the sum of a `List Int`
-   Rewrite it as a recursive function and verify both versions produce the same result on `[1, 2, 3, 4, 5]`

### Pair Swap

-   Write `swap : α × β → β × α` that exchanges the two elements of a pair
-   Verify with `#guard` that `swap ("hello", 42) == (42, "hello")`

### Filtered Sum

-   Use `filter` and `foldl` together to sum only the even numbers in a `List Int`
-   Verify the result on `[1, 2, 3, 4, 5, 6]` is 12
