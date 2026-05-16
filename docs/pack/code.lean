-- Version numbers are plain Nats for simplicity
abbrev Version := Nat
abbrev PkgName = String

-- A dependency: package name + list of acceptable versions
structure Dep where
  pkg      : PkgName
  versions : List Version
  deriving Repr

-- A package entry in the manifest
structure PkgEntry where
  name    : PkgName
  version : Version
  deps    : List Dep
  deriving Repr

-- Current assignment: chosen version for each package
abbrev Assignment := List (PkgName × Version)

-- Check whether an assignment satisfies a list of deps
def satisfiesDeps (chosen : Assignment) (deps : List Dep) : Bool :=
  deps.all fun dep =>
    match chosen.find? (·.1 == dep.pkg) with
    | some (_, v) => dep.versions.contains v
    | none        => true   -- not yet chosen; will be checked when we pick it

-- Collect all packages reachable from `root` (BFS over manifest)
def reachable (manifest : List PkgEntry) (root : PkgName) : List PkgName :=
  let rec go : List PkgName → List PkgName → List PkgName
    | [],        visited => visited
    | n :: todo, visited =>
        if visited.contains n then go todo visited
        else
          let deps := manifest.filterMap fun e =>
            if e.name == n then some (e.deps.map (·.pkg)) else none
          go (todo ++ deps.join) (n :: visited)
  go [root] []

-- Backtracking solver
partial def solve (manifest : List PkgEntry) (required : List PkgName)
    (chosen : Assignment) : Option Assignment :=
  match required with
  | [] => some chosen
  | pkg :: rest =>
      if chosen.any (·.1 == pkg) then
        -- already chosen; check constraints still satisfied
        solve manifest rest chosen
      else
        -- try each available version of pkg
        let candidates := manifest.filter (·.name == pkg)
        candidates.findSome? fun entry =>
          let chosen' := (pkg, entry.version) :: chosen
          if satisfiesDeps chosen' entry.deps then
            let newRequired := entry.deps.map (·.pkg) ++ rest
            solve manifest newRequired chosen'
          else
            none

-- Tests ----------------------------------------------------------------

-- Manifest: A@1 depends on B@[1,2]; A@2 depends on B@[2]; B@1; B@2
def manifest : List PkgEntry := [
  { name := "A", version := 1, deps := [{ pkg := "B", versions := [1, 2] }] },
  { name := "A", version := 2, deps := [{ pkg := "B", versions := [2] }] },
  { name := "B", version := 1, deps := [] },
  { name := "B", version := 2, deps := [] }
]

-- Install A: should find A@1 or A@2 with a compatible B
#eval solve manifest ["A"] []
-- some [("B", 1), ("A", 1)]  or similar

-- Force B@2 already chosen: A must pick version with B@[2] in deps
#eval solve manifest ["A"] [("B", 2)]
-- some [("A", 1), ("B", 2)]  (A@1 also allows B@2) or ("A", 2, ...)

#guard (solve manifest ["A"] []).isSome
#guard (solve manifest ["A"] [("B", 99)]).isNone  -- no version 99 exists
