-- find? returns Some of the first element matching the predicate
def lookup (key : String) (pairs : List (String × Int)) : Option Int :=
  (pairs.find? (·.1 == key)).map (·.2)

#guard lookup "b" [("a", 1), ("b", 2), ("c", 3)] == some 2
#guard lookup "z" [("a", 1), ("b", 2)] == none

-- filterMap applies a function and keeps only the Some results
def onlyEvens (xs : List Nat) : List Nat :=
  xs.filterMap fun n => if n % 2 == 0 then some n else none

#guard onlyEvens [1, 2, 3, 4, 5] == [2, 4]

-- findSome? returns the first Some produced by the function
def firstOver (limit : Int) (xs : List Int) : Option Int :=
  xs.findSome? fun x => if x > limit then some x else none

#guard firstOver 3 [1, 2, 4, 5] == some 4
#guard firstOver 10 [1, 2, 4, 5] == none

-- Combine find? with map for safe lookups in association lists
def scores : List (String × Nat) := [("Alice", 95), ("Bob", 80)]

def grade (name : String) : String :=
  match (scores.find? (·.1 == name)).map (·.2) with
  | some s => if s >= 90 then "A" else "B"
  | none   => "unknown"

#eval grade "Alice"    -- "A"
#eval grade "Bob"      -- "B"
#eval grade "Carol"    -- "unknown"
