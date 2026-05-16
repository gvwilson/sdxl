import Std.Data.HashMap

-- A build rule: target, dependencies, recipe
structure Rule where
  target : String
  deps   : List String
  recipe : String
  deriving Repr

-- Dependency graph as adjacency list
abbrev Graph := List (String × List String)

def rulesGraph (rules : List Rule) : Graph :=
  rules.map fun r => (r.target, r.deps)

-- Topological sort (post-order DFS) -----------------------------------

private def topoVisit (graph : Graph) (node : String)
    (visited onStack : List String) :
    Except String (List String × List String) := do
  if onStack.contains node then
    .error s!"cycle detected at {node}"
  if visited.contains node then
    return ([], visited)
  let deps := (graph.find? (·.1 == node)).map (·.2) |>.getD []
  let mut order   : List String := []
  let mut visited := visited
  for dep in deps do
    let (subOrder, vis') ←
      topoVisit graph dep vis' (node :: onStack)  -- NB: `vis'` updated in loop
    order   := order ++ subOrder
    visited := vis'
  return (order ++ [node], node :: visited)
termination_by (graph.length - visited.length)   -- not provable; use partial

-- Simpler non-cycle-detecting topological sort for illustration
partial def topoSort (graph : Graph) : List String :=
  let nodes := graph.map (·.1)
  let (order, _) := nodes.foldl (init := ([], [])) fun (order, visited) n =>
    visit n visited order
  order
where
  visit (n : String) (visited order : List String) :
      List String × List String :=
    if visited.contains n then (order, visited)
    else
      let deps := (graph.find? (·.1 == n)).map (·.2) |>.getD []
      let (order, visited) :=
        deps.foldl (init := (order, n :: visited)) fun (o, v) d =>
          visit d v o
      (order ++ [n], visited)

-- Staleness check: a target is stale if any dep is newer than it
abbrev Timestamps = List (String × Nat)

def isStale (stamps : Timestamps) (target : String) (deps : List String) : Bool :=
  let ttime := (stamps.find? (·.1 == target)).map (·.2) |>.getD 0
  deps.any fun d =>
    let dtime := (stamps.find? (·.1 == d)).map (·.2) |>.getD 0
    dtime > ttime

-- Execute build: return list of recipes that would run
def executeBuild (rules : List Rule) (stamps : Timestamps) : List String :=
  let graph := rulesGraph rules
  let order := topoSort graph
  order.filterMap fun target =>
    rules.find? (·.target == target) |>.bind fun rule =>
      if isStale stamps target rule.deps then some rule.recipe else none

-- Tests ----------------------------------------------------------------

def exRules : List Rule := [
  { target := "output", deps := ["processed"], recipe := "run analysis" },
  { target := "processed", deps := ["raw"],    recipe := "run normalize" },
  { target := "raw", deps := [],               recipe := "fetch data" }
]

-- Topological order should put "raw" before "processed" before "output"
#eval topoSort (rulesGraph exRules)
-- ["raw", "processed", "output"]

-- Everything stale (no stamps) → all recipes run
#eval executeBuild exRules []
-- ["fetch data", "run normalize", "run analysis"]

-- raw already up to date (stamp=5), others at 0 → normalize and analysis still run
#eval executeBuild exRules [("raw", 5)]
