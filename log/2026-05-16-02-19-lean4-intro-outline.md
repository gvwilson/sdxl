# Lean4 Introduction Outline

**Session:** 2026-05-16 02:19 UTC
**Task:** Survey Lean4 features used in `*/*.lean` and outline an introductory lesson sequence.

## Prompt

Create a new log file. Look at the features of Lean4 used in the `*/*.lean` files. Briefly outline
an introduction to Lean4 that introduces the features used in these lessons. The introduction may
span several one-hour lessons, but they must build on each other.

## Features Found in Lesson Code

Surveyed 18 files: `archive`, `binary`, `build`, `check`, `db`, `docgen`, `dup`, `func`, `glob`,
`interp`, `layout`, `lint`, `oop`, `pack`, `parse`, `template`, `test`, `vm`.

### Definitions and declarations
- `def` (plain functions), `abbrev` (transparent type aliases), `private`, `partial`
- `structure` (record/product types) with `deriving Repr`
- `inductive` (sum types / ADTs) with `deriving Repr, BEq`
- `theorem` with `by decide` and `by native_decide`
- `#eval`, `#guard` for interactive checks and compile-time assertions

### Types used
Scalar: `Int`, `Nat`, `Bool`, `Float`, `String`, `Char`, `UInt8`, `UInt16`, `UInt64`
Compound: `List α`, `Array α`, `Option α`, `Except α β`, `IO α`, `Fin n`
Tuples: `α × β` (including nested), destructuring in `let` and `fun`

### Pattern matching
- `match` expressions (exhaustive, nested, wildcard `_`)
- Function definitions by equation (cases on left-hand side)
- Constructor dot-notation in patterns: `.ok`, `.error`, `.Int`, etc.

### List and collection operations
`map`, `foldl`, `filter`, `filterMap`, `find?`, `findSome?`, `any`, `all`, `bind`,
`contains`, `zip`, `join`, `eraseDups`, `count`, `reverse`, `mapM`, `filterMapM`

### Lambda and dot shorthand
- `fun x => expr`, `fun (a, b) => expr`
- Anonymous function shorthand: `(· + ·.w)`, `(·.1 == k)`

### String interpolation
- `s!"text {expr} more text"`

### Monadic `do` notation
- `Option` monad: `do pure ((← eval a) + (← eval b))`
- `Except` monad: `.ok`, `.error`, `←` for short-circuit propagation
- `IO` monad: `←` for effects, `return`, `for x in xs do`
- `Id.run do` with `let mut` for local imperative state

### Mutable local state
- `let mut x := ...` inside `do` or `Id.run do`
- `for ... in ... do` loops

### Structure features
- Field access: `s.field`
- Record update: `{ s with field := newVal }`
- Anonymous constructor: `{ field1 := v1, field2 := v2 }`

### Type classes
- `class Name (α : Type) where ...`
- `instance : Name T where ...`
- Constrained polymorphism: `{α : Type} [Shape α] [Repr α]`
- Standard classes: `BEq`, `Hashable`, `Repr`

### Termination and recursion
- Structural recursion (default, checked by elaborator)
- `partial` for functions without a provable measure
- `termination_by expr` annotation
- `where` clauses for local helper definitions
- `let rec` inside definitions

### Numeric and bitwise operations
- `>>>`, `<<<`, `&&&`, `|||`, `~~~` (shift, bitwise AND/OR/NOT)
- Fixed-width overflow (`UInt8` wraps at 256)
- `Fin n` for bounded indices

### Array literals
- `#[elem, ...]`

---

## Proposed Introduction: Five One-Hour Lessons

Each lesson builds directly on the previous one. Code examples should be runnable snippets
that learners can paste into the Lean4 VS Code extension or `lake env lean`.

---

### Lesson 1: Values, Types, and Simple Functions

*Goal: write and check small pure functions; understand Lean's type-first design.*

- `def`, explicit type annotations (`x : T`), return types
- Scalar types: `Int`, `Nat`, `String`, `Bool`
- `#eval` (evaluate and print) and `#guard` (compile-time assertion)
- `let` bindings inside definitions
- String interpolation: `s!"result = {n}"`
- `List` basics: `[1, 2, 3]`, `List.map`, `List.filter`
- Lambda functions: `fun x => x + 1`
- `abbrev` for readable type aliases

*Connects to:* `binary/code.lean` (scalar types, `def`), `test/code.lean` (`#guard`, `#eval`),
`interp/code.lean` (`abbrev Env`).

---

### Lesson 2: Algebraic Data Types and Pattern Matching

*Goal: model data with `structure` and `inductive`; use `match` instead of conditionals.*

- `structure` with named fields, `deriving Repr`
- Field access (`s.field`) and anonymous constructors (`{ field := val }`)
- `inductive` types: defining a type with multiple constructors
- `match` expressions (exhaustive; Lean rejects incomplete matches)
- Equation-style function definitions (pattern on left-hand side)
- `abbrev` to name tuple types
- Dot-notation patterns: `.Ok`, `.Error` (preview of `Except`)

*Connects to:* `interp/code.lean` (`inductive Expr`), `check/code.lean` (`inductive Node`,
`structure Visitor`), `layout/code.lean` (`inductive Cell`, `structure Size`).

---

### Lesson 3: Option, Lists in Depth, and Functional Idioms

*Goal: handle missing values without null; chain list transformations fluently.*

- `Option α`: `some v` and `none`
- Pattern matching on `Option`; why `null` is not Lean's answer
- `Option.map`, `Option.getD`, `Option.bind`, `Option.join`
- List library in depth: `foldl`, `filterMap`, `find?`, `any`, `all`, `zip`, `bind`
- Anonymous field shorthand: `(·.1 == "key")`
- `do` notation for `Option` (monadic early exit without exceptions)

*Connects to:* `interp/code.lean` (`envLookup`, `eval` returning `Option`),
`db/code.lean` (`dbGet`, tombstone pattern), `dup/code.lean` (`groupBy`).

---

### Lesson 4: Error Handling and the IO Monad

*Goal: propagate errors explicitly with `Except`; write programs that read and write files.*

- `Except ε α`: `.ok v` and `.error msg`
- Contrast with `Option`: errors carry information
- `do` notation with `Except`: `←` short-circuits on `.error`
- `IO α`: the type of effectful computations
- `do` in `IO`: `let x ← action`, `return v`, `for x in xs do`
- `IO.FS` basics: `readFile`, `writeFile`, `readBinFile`, `writeBinFile`
- Pure-core / IO-wrapper pattern: keep business logic in pure functions, call from `IO`

*Connects to:* `func/code.lean` (`eval` returning `Except`), `archive/code.lean`
(`buildManifest` pure + `snapshot` in `IO`), `db/code.lean` (`appendEntry`, `readLog`).

---

### Lesson 5: Type Classes, Recursion, and Local Mutation

*Goal: write polymorphic code with type classes; handle unbounded recursion safely.*

- `class Name (α : Type) where ...`: defining an interface
- `instance : Name T where ...`: implementing it
- Constrained generics: `{α : Type} [Shape α]`; contrast with Java interfaces
- Standard classes: `BEq`, `Hashable`, `Repr`; `deriving` shortcut
- Structural recursion: why Lean checks termination and what "fuel" means
- `partial`: opting out of the termination check and the tradeoff
- `termination_by` annotations for non-obvious measures
- `where` clauses for private helpers attached to a definition
- `let mut` and `Id.run do` for imperative local state when functional style is awkward

*Connects to:* `oop/code.lean` (`class Shape`, `instance`), `glob/code.lean` (`partial def glob`),
`pack/code.lean` (`partial def solve`, `let rec go`), `docgen/code.lean` (`Id.run do`, `let mut`).

---

## Notes for Lesson Ordering

- Lessons 1-3 are purely functional and require no package setup beyond the core Lean4 toolchain.
- Lesson 4 introduces `IO`; learners need `lake` to run effectful programs.
- Lesson 5 is the most conceptually dense and should come last; `partial` and `let mut` both
  require understanding why Lean is stricter than Python before the relaxations make sense.
- Proofs (`theorem`, `decide`) appear in `test/code.lean` but are not central to the design-by-example
  lessons; they could be a brief aside in Lesson 1 or a standalone appendix.
