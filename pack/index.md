# A Package Manager

## Outline

- Represent a package manifest as a list of `(name, version, deps)` triples where
  each dep is `(name, allowed-versions)`
- Finding a valid install is a constraint-satisfaction search: pick one version per
  package, check all dependency constraints
- Backtracking search: for each required package, try each available version; recurse
  with updated `chosen` map; fail if a constraint is violated
- Pruning: before recursing, check whether the chosen version satisfies all currently
  chosen constraints to cut the search space
- Lean's `Except` monad carries either a valid assignment or a failure message

## Code

[%inc code.lean %]
