-- Structural recursion: Lean verifies the argument shrinks at each call
def sumList : List Int → Int
  | []      => 0
  | x :: xs => x + sumList xs

#guard sumList [1, 2, 3, 4, 5] == 15

-- termination_by: explicit measure for when Lean cannot infer one
def countdown (n : Nat) : List Nat :=
  if n == 0 then [0] else n :: countdown (n - 1)
termination_by n

#guard countdown 3 == [3, 2, 1, 0]

-- partial: opt out of termination checking; the function may loop
partial def collatz : Nat → List Nat
  | 1 => [1]
  | n => n :: collatz (if n % 2 == 0 then n / 2 else 3 * n + 1)

#eval collatz 6    -- [6, 3, 10, 5, 16, 8, 4, 2, 1]

-- where: private helper attached to its parent, invisible outside
def frequencies (xs : List String) : List (String × Nat) :=
  xs.foldl tally []
where
  tally (acc : List (String × Nat)) (s : String) : List (String × Nat) :=
    match acc.find? (·.1 == s) with
    | some (_, n) => acc.map fun p => if p.1 == s then (s, n + 1) else p
    | none        => acc ++ [(s, 1)]

#eval frequencies ["a", "b", "a", "c", "b", "a"]
-- [("a", 3), ("b", 2), ("c", 1)]

-- Id.run do and let mut: local mutable state without IO
def countVowels (s : String) : Nat := Id.run do
  let mut n := 0
  for c in s.toList do
    if "aeiouAEIOU".contains c then
      n := n + 1
  return n

#guard countVowels "hello world" == 3
