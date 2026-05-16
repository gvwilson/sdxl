# Matching Patterns

## Outline

- Represent a glob pattern as a flat list of `Elem` values: `Lit`, `Any` (?), `Wild` (*)
- Chain of Responsibility: each element tries to match the front of the input,
  then passes the rest to the remaining elements
- `Any` matches exactly one character; `Wild` matches zero or more (with backtracking)
- `glob` is `partial` because the `Wild` case retries with shorter suffixes
- `matchGlob` wraps `glob` for whole-string matching

## Code

[%inc code.lean %]
