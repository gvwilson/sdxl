-- Option α is either (some value) or none; there is no null in Lean
def safeDivide (a b : Int) : Option Int :=
  if b == 0 then none else some (a / b)

#guard safeDivide 10 2 == some 5
#guard safeDivide 10 0 == none

-- map transforms the value if present; none passes through unchanged
#guard (safeDivide 10 2).map (· * 3) == some 15
#guard (safeDivide 10 0).map (· * 3) == none

-- getD supplies a default when the value is absent
#guard (safeDivide 10 0).getD (-1) == -1

-- Explicit pattern match when the two branches need different logic
def describe (a b : Int) : String :=
  match safeDivide a b with
  | some q => s!"{a} / {b} = {q}"
  | none   => "cannot divide by zero"

#eval describe 10 3    -- "10 / 3 = 3"
#eval describe 10 0    -- "cannot divide by zero"

-- do notation: each <- short-circuits the chain if the result is none
def compute (a b c : Int) : Option Int := do
  let x ← safeDivide a b
  let y ← safeDivide x c
  return x + y

#guard compute 10 2 1 == some 10   -- x=5, y=5, x+y=10
#guard compute 10 0 1 == none      -- first step fails; chain stops
