-- Pattern elements
inductive Elem where
  | Lit  : Char → Elem   -- literal character
  | Any  : Elem          -- match exactly one char  (?)
  | Wild : Elem          -- match zero or more chars (*)
  deriving Repr, BEq

-- Chain of Responsibility: consume the matched prefix, return remaining chars.
-- Uses partial because Wild tries every suffix without a decreasing measure.
partial def glob : List Elem → List Char → Bool
  | [],             []        => true
  | [],             _         => false
  | Elem.Lit c :: ps, c' :: cs => c == c' && glob ps cs
  | Elem.Lit _ :: _,  []      => false
  | Elem.Any   :: ps, _ :: cs => glob ps cs
  | Elem.Any   :: _,  []      => false
  | Elem.Wild  :: [],  _      => true          -- * at end matches anything
  | Elem.Wild  :: ps,  cs     =>               -- try every split point
      (List.range (cs.length + 1)).any fun i =>
        glob ps (cs.drop i)

def matchGlob (pat : List Elem) (s : String) : Bool :=
  glob pat s.toList

-- Helper to build a Lit element list from a string
def litPat (s : String) : List Elem := s.toList.map Elem.Lit

#guard matchGlob (litPat "hello") "hello"
#guard matchGlob (litPat "hi" ++ [Elem.Wild]) "hiXYZ"
#guard matchGlob [Elem.Wild] ""
#guard matchGlob [Elem.Wild] "anything"
#guard matchGlob ([Elem.Wild] ++ litPat ".txt") "report.txt"
#guard matchGlob [Elem.Any] "x"
#guard !matchGlob [Elem.Any] ""
#guard !matchGlob [Elem.Any] "xy"
#guard !matchGlob (litPat "foo") "bar"
