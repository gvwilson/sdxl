-- The function under test
def sign (n : Int) : Int :=
  if n > 0 then 1 else if n < 0 then -1 else 0

-- Mechanism 1: #guard
-- Evaluates at compile time; build fails if the expression is not true.
-- No proof is produced — this is a quick sanity check.
#guard sign 19   == 1
#guard sign (-3) == -1
#guard sign 0    == 0

-- Mechanism 2: decide
-- Closes a *proof goal* by kernel evaluation.
-- The result is a term of type `sign 19 = 1`, not just a Bool.
theorem sign_positive : sign 19 = 1 := by decide
theorem sign_negative : sign (-3) = -1 := by decide
theorem sign_zero     : sign 0 = 0 := by decide

-- native_decide: same as decide but compiles to native code first.
-- Use when decide times out (e.g., large Nat computations).
theorem sign_large_pos : sign 1000000 = 1 := by native_decide

-- Mechanism 3: LSpec-style named test runner
-- (Requires the LSpec package: https://github.com/lurk-lab/LSpec)
-- Shown here as a pattern; remove the `-- ` prefix when LSpec is available.
--
-- import LSpec
--
-- #lspec
--   test "positive" (sign 19 = 1) $
--   test "negative" (sign (-3) = -1) $
--   test "zero"     (sign 0 = 0)
--
-- For property-based testing (SlimCheck integration):
--
-- #lspec check "sign never exceeds 1" $ ∀ n : Int, sign n ≤ 1

-- Key contrast with Python:
-- Python: `pytest` discovers tests AT RUNTIME by scanning __dict__ for "test_*"
--         functions → requires reflection, impossible in Lean.
-- Lean:   tests are either compile-time checks (#guard) or proof obligations
--         (decide), verified by the type-checker before the program runs.
--         This makes failures impossible to miss and proofs machine-checkable.

-- A hand-rolled test runner (to illustrate the Python lesson's idea):
-- Since we cannot iterate over functions by name, we store them in a list explicitly.
structure TestCase where
  name   : String
  result : Bool   -- true = pass

def runTests (cases : List TestCase) : List String :=
  cases.filterMap fun t =>
    if t.result then none else some s!"FAIL: {t.name}"

def myTests : List TestCase := [
  { name := "positive", result := (sign 19 == 1)   },
  { name := "negative", result := (sign (-3) == -1) },
  { name := "zero",     result := (sign 0 == 0)     }
]

#eval runTests myTests   -- []  (all pass)

#guard runTests myTests == []
