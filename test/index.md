# Running Tests

## Outline

- Python's test runner uses **runtime reflection** to discover tests: it scans
  dictionaries for functions whose names start with `test_`. Lean has no runtime
  reflection, so this specific design does not translate.
- Instead, Lean has three complementary testing mechanisms:
  1. `#guard` — compile-time boolean check; fails the build if false
  2. `decide` / `native_decide` — **proof tactics** that close decidable propositions;
     the result is a kernel-verified proof term, not just a check
  3. **LSpec** (third-party) — named test suites with pass/fail reporting and
     property-based testing via `SlimCheck`
- This lesson therefore teaches Lean's own model and contrasts it with Python's

## Code

[%inc code.lean %]
