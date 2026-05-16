-- List literal; all elements share the same type
def primes : List Nat := [2, 3, 5, 7, 11]

-- map transforms every element
#eval primes.map (· * 2)      -- [4, 6, 10, 14, 22]

-- filter keeps only matching elements
#eval primes.filter (· > 5)   -- [7, 11]

-- foldl accumulates from the left: foldl f init [a,b,c] = f (f (f init a) b) c
def total : List Int → Int := List.foldl (· + ·) 0
#guard total [1, 2, 3, 4, 5] == 15

-- Tuple type α × β; construct with (a, b); access with .1 and .2
def pair : String × Nat := ("Alice", 30)
#guard pair.1 == "Alice"
#guard pair.2 == 30

-- List of tuples is the standard key-value structure
def scores : List (String × Nat) := [("Alice", 95), ("Bob", 80), ("Carol", 90)]

-- Lambda with tuple destructuring
#eval scores.map (fun (name, score) => s!"{name}: {score}")
-- ["Alice: 95", "Bob: 80", "Carol: 90"]

-- foldl with a multi-argument lambda to find the highest score
def best (xs : List (String × Nat)) : Nat :=
  xs.foldl (fun hi (_, s) => max hi s) 0

#guard best scores == 95
