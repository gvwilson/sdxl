-- A contract: any type that can report its area and perimeter
class Shape (α : Type) where
  area      : α → Float
  perimeter : α → Float

structure Circle where
  radius : Float
  deriving Repr

structure Square where
  side : Float
  deriving Repr

def pi : Float := 3.14159265358979

instance : Shape Circle where
  area c      := pi * c.radius * c.radius
  perimeter c := 2.0 * pi * c.radius

instance : Shape Square where
  area s      := s.side * s.side
  perimeter s := 4.0 * s.side

-- Polymorphic: works for any type with a Shape instance
def describe {α : Type} [Shape α] [Repr α] (x : α) : String :=
  s!"area={Shape.area x} perimeter={Shape.perimeter x}"

-- Existential wrapper so we can put mixed shapes in one list
structure AnyShape where
  area      : Float
  perimeter : Float

def wrap {α : Type} [Shape α] (x : α) : AnyShape :=
  { area := Shape.area x, perimeter := Shape.perimeter x }

def totalArea (shapes : List AnyShape) : Float :=
  shapes.foldl (init := 0.0) (· + ·.area)

#eval describe (Circle.mk 1.0)
#eval describe (Square.mk 3.0)

#eval totalArea [wrap (Circle.mk 1.0), wrap (Square.mk 2.0)]

#guard Shape.area (Square.mk 3.0) == 9.0
#guard Shape.perimeter (Square.mk 3.0) == 12.0
