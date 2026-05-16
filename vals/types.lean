-- Every value has a type; Int is signed, Nat is non-negative
def answer : Int := 6 * 7
def greeting : String := "hello"
def passed : Bool := true

-- #eval prints a value at compile time
#eval answer      -- 42
#eval greeting    -- "hello"

-- #guard asserts at compile time; a failing guard is a build error
#guard answer == 42
#guard greeting.length == 5

-- let binds a local immutable name inside a definition
def circleArea (r : Float) : Float :=
  let pi : Float := 3.14159265
  pi * r * r

#eval circleArea 2.0    -- 12.5663706

-- abbrev creates a transparent alias for an existing type
abbrev Name  = String
abbrev Score = Nat

-- s!"..." converts expressions to text inline
def report (n : Name) (s : Score) : String :=
  s!"{n} scored {s} points"

#eval report "Alice" 95    -- "Alice scored 95 points"
