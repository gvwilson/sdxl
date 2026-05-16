-- Structure: a product type with named fields
structure Point where
  x : Float
  y : Float
  deriving Repr, BEq

-- Construct, access, and update
def origin : Point := { x := 0.0, y := 0.0 }

#eval origin.x                          -- 0.0
#eval { origin with x := 3.0 }         -- { x := 3.0, y := 0.0 }

-- Inductive: a sum type whose value is exactly one constructor
inductive Direction where
  | North | South | East | West
  deriving Repr, BEq

-- match must cover every constructor; Lean rejects incomplete matches
def opposite : Direction → Direction
  | Direction.North => Direction.South
  | Direction.South => Direction.North
  | Direction.East  => Direction.West
  | Direction.West  => Direction.East

#guard opposite Direction.North == Direction.South
#guard opposite (opposite Direction.East) == Direction.East

-- Constructors can carry data; each carries a different payload
inductive Shape where
  | Circle : Float → Shape
  | Rect   : Float → Float → Shape
  deriving Repr

def area : Shape → Float
  | Shape.Circle r   => 3.14159 * r * r
  | Shape.Rect w h   => w * h

#guard area (Shape.Rect 3.0 4.0) == 12.0
#guard area (Shape.Circle 1.0) == 3.14159

-- Recursive inductive: a binary tree refers to itself
inductive Tree where
  | Leaf : Tree
  | Node : Tree → Int → Tree → Tree
  deriving Repr

def treeSum : Tree → Int
  | Tree.Leaf         => 0
  | Tree.Node l v r   => treeSum l + v + treeSum r

--     2
--    / \
--   1   3
def sample : Tree :=
  Tree.Node
    (Tree.Node Tree.Leaf 1 Tree.Leaf)
    2
    (Tree.Node Tree.Leaf 3 Tree.Leaf)

#guard treeSum sample == 6
