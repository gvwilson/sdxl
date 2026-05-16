-- Cell tree
inductive Cell where
  | Block : (w h : Nat) → Cell
  | Row   : List Cell → Cell
  | Col   : List Cell → Cell
  deriving Repr

-- Computed size
structure Size where
  w h : Nat
  deriving Repr

-- Placed cell (origin + size)
structure Rect where
  x y w h : Nat
  deriving Repr

-- Pass 1: compute sizes bottom-up
def cellSize : Cell → Size
  | Cell.Block w h => { w, h }
  | Cell.Row   cs  =>
      let sizes := cs.map cellSize
      { w := sizes.foldl (· + ·.w) 0
        h := sizes.foldl (fun m s => max m s.h) 0 }
  | Cell.Col   cs  =>
      let sizes := cs.map cellSize
      { w := sizes.foldl (fun m s => max m s.w) 0
        h := sizes.foldl (· + ·.h) 0 }

-- Pass 2: assign positions top-down, collect Rect list
def place (x y : Nat) : Cell → List Rect
  | Cell.Block w h => [{ x, y, w, h }]
  | Cell.Row cs    =>
      let (rects, _) := cs.foldl (init := ([], x)) fun (acc, cx) c =>
        let sz := cellSize c
        (acc ++ place cx y c, cx + sz.w)
      rects
  | Cell.Col cs    =>
      let (rects, _) := cs.foldl (init := ([], y)) fun (acc, cy) c =>
        let sz := cellSize c
        (acc ++ place x cy c, cy + sz.h)
      rects

def layout (c : Cell) : List Rect := place 0 0 c

-- Tests ----------------------------------------------------------------

-- A row of two blocks: [2×3] [4×1]  →  width=6, height=3
#guard cellSize (Cell.Row [Cell.Block 2 3, Cell.Block 4 1]) == { w := 6, h := 3 }

-- A column of two blocks: [2×3] stacked over [2×1]  →  height=4, width=2
#guard cellSize (Cell.Col [Cell.Block 2 3, Cell.Block 2 1]) == { w := 2, h := 4 }

-- Placement of a row
#eval layout (Cell.Row [Cell.Block 2 3, Cell.Block 4 1])
-- [{ x:0 y:0 w:2 h:3 }, { x:2 y:0 w:4 h:1 }]

-- Placement of a column
#eval layout (Cell.Col [Cell.Block 5 2, Cell.Block 5 3])
-- [{ x:0 y:0 w:5 h:2 }, { x:0 y:2 w:5 h:3 }]
