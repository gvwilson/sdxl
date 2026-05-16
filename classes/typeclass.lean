-- class defines an interface: a set of functions any type can implement
class Describable (α : Type) where
  describe : α → String

-- Concrete types have no knowledge of each other
structure Point where
  x y : Float
  deriving Repr

structure Color where
  r g b : Nat
  deriving Repr

-- instance provides the implementation for a specific type
instance : Describable Point where
  describe p := s!"({p.x}, {p.y})"

instance : Describable Color where
  describe c := s!"rgb({c.r}, {c.g}, {c.b})"

-- [Describable α] constrains the type variable: works for any type with an instance
def label {α : Type} [Describable α] (x : α) : String :=
  s!"value: {Describable.describe x}"

def p1 : Point := { x := 1.0, y := 2.0 }
def c1 : Color := { r := 255, g := 0, b := 0 }

#eval label p1    -- "value: (1.0, 2.0)"
#eval label c1    -- "value: rgb(255, 0, 0)"

-- The same constraint applies to list operations
def describeAll {α : Type} [Describable α] (xs : List α) : List String :=
  xs.map Describable.describe

#eval describeAll [p1, { x := 0.0, y := 0.0 }]
-- ["(1.0, 2.0)", "(0.0, 0.0)"]

-- deriving BEq generates == without writing an instance by hand
structure Tag where
  name : String
  deriving BEq, Repr

#guard ({ name := "lean" } : Tag) == { name := "lean" }
#guard !( ({ name := "lean" } : Tag) == { name := "coq" } )
