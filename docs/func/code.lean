-- Values are either integers or closures
inductive Value where
  | Int     : Int → Value
  | Closure : List String → Expr → Env → Value
  deriving Repr

-- Environments map names to values
abbrev Env := List (String × Value)

-- Extended expression tree
inductive Expr where
  | Num  : Int → Expr
  | Var  : String → Expr
  | Add  : Expr → Expr → Expr
  | Sub  : Expr → Expr → Expr
  | Mul  : Expr → Expr → Expr
  | Func : List String → Expr → Expr   -- anonymous function
  | Call : Expr → List Expr → Expr     -- function application
  deriving Repr

def envLookup (name : String) (env : Env) : Option Value :=
  (env.find? (·.1 == name)).map (·.2)

-- Evaluation: returns a Value or an error string
def eval (env : Env) : Expr → Except String Value
  | Expr.Num n     => .ok (.Int n)
  | Expr.Var name  =>
      match envLookup name env with
      | some v => .ok v
      | none   => .error s!"undefined: {name}"
  | Expr.Add a b   => do
      let .Int x ← eval env a | .error "not an int"
      let .Int y ← eval env b | .error "not an int"
      .ok (.Int (x + y))
  | Expr.Sub a b   => do
      let .Int x ← eval env a | .error "not an int"
      let .Int y ← eval env b | .error "not an int"
      .ok (.Int (x - y))
  | Expr.Mul a b   => do
      let .Int x ← eval env a | .error "not an int"
      let .Int y ← eval env b | .error "not an int"
      .ok (.Int (x * y))
  -- Creating a function captures the current environment (closure)
  | Expr.Func params body =>
      .ok (.Closure params body env)
  -- Calling a function: evaluate args, bind to params, eval body in new env
  | Expr.Call fnExpr argExprs => do
      let fnVal ← eval env fnExpr
      match fnVal with
      | .Closure params body closedEnv =>
          if params.length != argExprs.length then
            .error "arity mismatch"
          else
            let args ← argExprs.mapM (eval env)
            let frame := params.zip args ++ closedEnv
            eval frame body
      | _ => .error "not a function"

-- Helpers
def defun (params : List String) (body : Expr) : Expr := Expr.Func params body
def call  (fn : Expr) (args : List Expr) : Expr := Expr.Call fn args

-- Tests ----------------------------------------------------------------

-- (fun x => x + 1)(5)  =  6
#guard eval [] (call (defun ["x"] (Expr.Add (Expr.Var "x") (Expr.Num 1)))
                     [Expr.Num 5])
      == .ok (.Int 6)

-- Closure captures outer variable:
-- let add = (fun x => x + n) with n=10; add(3) = 13
#guard eval [("n", .Int 10)]
  (call (defun ["x"] (Expr.Add (Expr.Var "x") (Expr.Var "n")))
        [Expr.Num 3])
  == .ok (.Int 13)
