-- The expression tree: each node is an operation or a value
inductive Expr where
  | Num : Int → Expr
  | Var : String → Expr
  | Add : Expr → Expr → Expr
  | Sub : Expr → Expr → Expr
  | Mul : Expr → Expr → Expr
  | Neg : Expr → Expr
  | Abs : Expr → Expr
  deriving Repr

-- Environment: variable name → value
abbrev Env := List (String × Int)

def envLookup (name : String) (env : Env) : Option Int :=
  (env.find? (·.1 == name)).map (·.2)

-- Recursive dispatch: each node type triggers its own operation
def eval (env : Env) : Expr → Option Int
  | Expr.Num n     => some n
  | Expr.Var name  => envLookup name env
  | Expr.Add a b   => do pure ((← eval env a) + (← eval env b))
  | Expr.Sub a b   => do pure ((← eval env a) - (← eval env b))
  | Expr.Mul a b   => do pure ((← eval env a) * (← eval env b))
  | Expr.Neg a     => do pure (-(← eval env a))
  | Expr.Abs a     => do pure (Int.natAbs (← eval env a))

-- Convenience: evaluate with no variables
def eval₀ : Expr → Option Int := eval []

-- Tests ----------------------------------------------------------------
-- (1 + 2) * -3  =>  -9
#guard eval₀ (Expr.Mul (Expr.Add (Expr.Num 1) (Expr.Num 2)) (Expr.Neg (Expr.Num 3)))
      == some (-9)

-- abs(-4) = 4
#guard eval₀ (Expr.Abs (Expr.Neg (Expr.Num 4))) == some 4

-- variable lookup
#guard eval [("x", 10)] (Expr.Add (Expr.Var "x") (Expr.Num 5)) == some 15

-- undefined variable
#guard eval [] (Expr.Var "z") == none
