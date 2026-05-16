-- Except ε α is either (.ok value) or (.error message)
def safeDivide (a b : Int) : Except String Int :=
  if b == 0 then .error "division by zero" else .ok (a / b)

#guard safeDivide 10 2 == .ok 5
#guard safeDivide 10 0 == .error "division by zero"

-- do notation with Except: <- short-circuits on .error
def compute (a b c : Int) : Except String Int := do
  let x ← safeDivide a b
  let y ← safeDivide x c
  return x + y

#guard compute 10 2 1 == .ok 10
#guard compute 10 0 1 == .error "division by zero"

-- Pure core: validate and transform data
def parseAge (s : String) : Except String Nat :=
  match s.toNat? with
  | none   => .error s!"not a number: {s}"
  | some n => if n > 150 then .error s!"unrealistic age: {n}" else .ok n

#guard parseAge "25"  == .ok 25
#guard parseAge "abc" == .error "not a number: abc"
#guard parseAge "200" == .error "unrealistic age: 200"

-- Pure helper: parse one "name,age" line
def parseLine (line : String) : Except String (String × Nat) :=
  match line.splitOn "," with
  | [name, age] => parseAge age.trim |>.map fun n => (name.trim, n)
  | _           => .error s!"bad format: {line}"

#guard parseLine "Alice, 30" == .ok ("Alice", 30)
#guard parseLine "Bob, abc"  == .error "not a number: abc"

-- IO wrapper: read, process each line, write results
-- Pure logic above is already tested; IO here is a thin shell
def processFile (inPath outPath : String) : IO Unit := do
  let text ← IO.FS.readFile inPath
  let results := text.splitOn "\n" |>.filterMap fun line =>
    match parseLine line with
    | .ok (name, age) => some s!"{name} is {age} years old"
    | .error _        => none
  let output := results.foldl (fun acc s => acc ++ s ++ "\n") ""
  IO.FS.writeFile outPath output
