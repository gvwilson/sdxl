# Error Handling and IO

## Except and IO

-   `Except ε α` represents a computation that either succeeds with `.ok v` or fails with `.error msg`
-   Unlike `Option`, the failure case carries a message that explains what went wrong
-   `do` notation works for `Except` the same way it does for `Option`: `←` short-circuits on `.error` and the message propagates automatically
-   `IO α` is the type of a computation that can perform side effects and return a value of type `α`; it cannot be called from pure code
-   Inside an `IO do` block, `let x ← action` runs `action` and binds its result; `return v` wraps a pure value
-   `IO.FS.readFile` and `IO.FS.writeFile` read and write text files; `IO.println` writes to standard output
-   A reliable pattern: write the core logic as a pure function returning `Except`, test it with `#guard`, then call it from a thin `IO` wrapper

[%inc code.lean %]

## Exercises

### Safe Square Root

-   Write `safeSqrt : Float → Except String Float` that returns `.error "negative input"` for values below zero
-   Verify on `4.0`, `0.0`, and `-1.0`

### Parse and Add

-   Write `parseAndAdd : String → String → Except String Int` that converts two strings to integers using `String.toInt?` and returns their sum
-   Convert the `Option` result to `Except` with a descriptive error message when parsing fails

### File Line Count

-   Write an `IO` function that reads a file and prints the number of lines it contains
-   Use `String.splitOn "\n"` to split the contents

### Validate and Chain

-   Write `validateName : String → Except String String` that returns `.error` when the name is empty or longer than 50 characters
-   Chain it with `parseAge` from the lesson using `do` notation to validate both a name and an age from strings
-   Return a formatted greeting on success
