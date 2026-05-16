-- Kinds of documented declarations
inductive DeclKind where
  | Module | Func | Struct | TypeClass
  deriving Repr, BEq

-- A source declaration with optional doc comment
structure Decl where
  kind    : DeclKind
  name    : String
  docStr  : Option String
  deriving Repr

-- A doc entry produced by extraction
structure DocEntry where
  kind   : DeclKind
  name   : String
  doc    : String       -- empty string if no comment
  deriving Repr

-- Extract documented declarations (skip undocumented ones)
def extract (decls : List Decl) : List DocEntry :=
  decls.filterMap fun d =>
    d.docStr.map fun doc => { kind := d.kind, name := d.name, doc }

-- Render to Markdown
def kindHeading : DeclKind → String
  | .Module    => "#"
  | .TypeClass => "##"
  | .Struct    => "##"
  | .Func      => "###"

def renderMarkdown (entries : List DocEntry) : String :=
  entries.foldl (init := "") fun acc e =>
    acc ++ s!"{kindHeading e.kind} {e.name}\n\n{e.doc}\n\n"

-- Simple line-by-line doc comment extractor for .lean source
-- Collects consecutive `-- ` lines before a `def`/`structure` declaration
def parseDecls (src : String) : List Decl := Id.run do
  let lines := src.splitOn "\n"
  let mut decls : List Decl := []
  let mut pendingDoc : Option String := none
  for line in lines do
    let stripped := line.trimLeft
    if stripped.startsWith "-- " then
      let comment := stripped.drop 3
      pendingDoc := some ((pendingDoc.getD "") ++ comment ++ " ")
    else if stripped.startsWith "def " then
      let name := (stripped.drop 4).takeWhile (· != ' ') |>.takeWhile (· != '(')
      decls := decls ++ [{ kind := .Func, name, docStr := pendingDoc }]
      pendingDoc := none
    else if stripped.startsWith "structure " then
      let name := (stripped.drop 10).takeWhile (· != ' ') |>.takeWhile (· != 'w')
      decls := decls ++ [{ kind := .Struct, name, docStr := pendingDoc }]
      pendingDoc := none
    else
      pendingDoc := none
  return decls

-- Tests ---------------------------------------------------------------

def sampleSrc : String :=
"-- Adds two numbers together.
def add (x y : Int) : Int := x + y

def hidden := 42

-- Holds a name and age.
structure Person where
  name : String
  age  : Nat"

#eval parseDecls sampleSrc
-- [{ kind: Func,   name: "add",    docStr: some "Adds two numbers together. " },
--  { kind: Func,   name: "hidden", docStr: none },
--  { kind: Struct, name: "Person", docStr: some "Holds a name and age. " }]

#eval renderMarkdown (extract (parseDecls sampleSrc))
-- ### add
--
-- Adds two numbers together.
--
-- ## Person
--
-- Holds a name and age.

#guard extract (parseDecls sampleSrc) |>.length == 2   -- only documented ones
