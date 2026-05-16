-- Simplified AST
inductive Expr where
  | Num  : Int → Expr
  | Var  : String → Expr
  | Dict : List (String × Expr) → Expr   -- {key: val, ...}
  | Call : String → List Expr → Expr
  deriving Repr

inductive Stmt where
  | Assign : String → Expr → Stmt
  | If     : Expr → Stmt → Stmt → Stmt
  | While  : Expr → Stmt → Stmt
  | Block  : List Stmt → Stmt
  | Expr   : Expr → Stmt
  deriving Repr

-- Visitor: collect results of type α by walking every node
def walkExpr {α} (onDict : List (String × Expr) → List α)
                 (e : Expr) : List α :=
  match e with
  | Expr.Dict pairs =>
      onDict pairs ++ pairs.bind (fun (_, v) => walkExpr onDict v)
  | Expr.Call _ args =>
      args.bind (walkExpr onDict)
  | _ => []

def walkStmt {α} (onDict : List (String × Expr) → List α)
                 (s : Stmt) : List α :=
  match s with
  | Stmt.Assign _ e   => walkExpr onDict e
  | Stmt.If c t f     => walkExpr onDict c
                      ++ walkStmt onDict t
                      ++ walkStmt onDict f
  | Stmt.While c b    => walkExpr onDict c ++ walkStmt onDict b
  | Stmt.Block stmts  => stmts.bind (walkStmt onDict)
  | Stmt.Expr e       => walkExpr onDict e

-- Linter 1: duplicate dictionary keys ---------------------------------

def dupKeys (pairs : List (String × Expr)) : List String :=
  let keys := pairs.map (·.1)
  keys.filter fun k => keys.count k > 1

def findDupKeys (s : Stmt) : List String :=
  walkStmt dupKeys s

-- Linter 2: assigned-but-unused variables in a block -----------------

def assignedVars (stmts : List Stmt) : List String :=
  stmts.filterMap fun s => match s with
    | Stmt.Assign name _ => some name
    | _                  => none

def usedVars (s : Stmt) : List String :=
  walkStmt (fun _ => []) s  -- not quite right; helper below
-- (proper version collects Var references)
def usedVarsExpr (e : Expr) : List String :=
  match e with
  | Expr.Var n     => [n]
  | Expr.Dict ps   => ps.bind (fun (_, v) => usedVarsExpr v)
  | Expr.Call _ as => as.bind usedVarsExpr
  | _              => []

def unusedVars (stmts : List Stmt) : List String :=
  let assigned := assignedVars stmts
  let used := stmts.bind fun s => match s with
    | Stmt.Assign _ e => usedVarsExpr e
    | Stmt.Expr e     => usedVarsExpr e
    | _               => []
  assigned.filter (fun v => !used.contains v)

-- Tests ----------------------------------------------------------------

def dupDict : Stmt :=
  Stmt.Expr (Expr.Dict [("a", Expr.Num 1), ("b", Expr.Num 2), ("a", Expr.Num 3)])

#guard findDupKeys dupDict == ["a", "a"]

def block : List Stmt := [
  Stmt.Assign "x" (Expr.Num 1),
  Stmt.Assign "y" (Expr.Num 2),
  Stmt.Expr (Expr.Var "x")   -- x used, y never used
]

#guard unusedVars block == ["y"]
