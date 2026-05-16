# A Build Manager

## Outline

- Represent build rules as `Rule`: target name, list of dependencies, recipe string
- Build the dependency graph as an adjacency list (`List (String × List String)`)
- Detect cycles with DFS (a node on the current path means a cycle)
- Topological sort via post-order DFS: add a node after all its dependencies
- Execute rules in topological order, skipping targets whose timestamps are fresh
- For this pure implementation, "timestamps" are modeled as a `Nat` lookup table

## Code

[%inc code.lean %]
