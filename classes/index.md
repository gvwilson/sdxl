# Type Classes and Recursion

## Type Classes

-   A `class` defines an interface: a set of functions that any type can implement
-   An `instance` declaration provides the implementation for one specific type; Lean selects the right instance by type inference at the call site
-   Write `{α : Type} [ClassName α]` to say a function works for any type that has an instance; the compiler rejects calls with types that do not
-   `deriving BEq` generates an `==` instance automatically; `deriving Hashable` does the same for hashing; `deriving Repr` enables `#eval`
-   Any type can get an instance at any time without modifying the type definition, unlike inheritance which requires a shared base class

[%inc typeclass.lean %]

## Recursion and Mutation

-   Lean checks that every recursive function terminates; it rejects functions with no provable decreasing measure
-   Mark a function `partial` to opt out of termination checking; Lean accepts it on faith, and it may loop forever
-   `termination_by expr` supplies an explicit decreasing measure when Lean cannot infer one automatically
-   `where` attaches private helper definitions to a function, keeping them out of the module's namespace
-   `let mut x := v` inside a `do` block creates a mutable local variable; update it with `x := newVal`
-   `Id.run do` runs a `do` block in the identity monad, giving access to `let mut` and `for` loops without requiring `IO`

[%inc recursion.lean %]

## Exercises

### Summable Class

-   Define `class Summable (α : Type)` with a method `zero : α` and `add : α → α → α`
-   Write instances for `Nat` and `Float`
-   Write a polymorphic `sumAll : [Summable α] → List α → α` and verify it on both types

### Tree Depth

-   Using the `Tree` type from the Algebraic Data Types lesson, write `depth : Tree → Nat` that returns the length of the longest root-to-leaf path
-   Verify Lean accepts the function without `partial` and that `Tree.Leaf` has depth `0`

### Fibonacci with Fuel

-   Write `fib (fuel n : Nat) : Nat` that returns the nth Fibonacci number, using `fuel` as the decreasing measure
-   Verify `fib 20 10 == 55`

### Mutable Character Count

-   Using `let mut` and a `for` loop inside `Id.run do`, count how many times each distinct character appears in a string
-   Return a `List (Char × Nat)` and verify it on a short string

### Flatten Without Partial

-   Write `flatten : List (List α) → List α` using structural recursion on the outer list
-   Verify Lean accepts it without `partial` and that `flatten [[1, 2], [3], [4, 5]] == [1, 2, 3, 4, 5]`
