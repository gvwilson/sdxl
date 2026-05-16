-- Template values
inductive TVal where
  | Str  : String → TVal
  | List : List Context → TVal
  deriving Repr
abbrev Context := List (String × TVal)

-- Template nodes
inductive TNode where
  | TText : String → TNode
  | TVar  : String → TNode                    -- {{ var }}
  | TLoop : String → TNode → TNode            -- {% for x in list %} body {% end %}
  | TIf   : String → TNode → TNode → TNode   -- {% if var %} then {% else %} else {% end %}
  | TSeq  : List TNode → TNode
  deriving Repr

def ctxGet (ctx : Context) (name : String) : Option TVal :=
  (ctx.find? (·.1 == name)).map (·.2)

-- Expand template to string
def expand (ctx : Context) : TNode → String
  | TNode.TText s     => s
  | TNode.TVar name   =>
      match ctxGet ctx name with
      | some (TVal.Str s) => s
      | _                 => ""
  | TNode.TLoop listName body =>
      match ctxGet ctx listName with
      | some (TVal.List items) =>
          items.foldl (init := "") fun acc itemCtx =>
            acc ++ expand (itemCtx ++ ctx) body
      | _ => ""
  | TNode.TIf varName thenNode elseNode =>
      match ctxGet ctx varName with
      | some (TVal.Str s) => if s.isEmpty then expand ctx elseNode
                             else expand ctx thenNode
      | some (TVal.List l) => if l.isEmpty then expand ctx elseNode
                              else expand ctx thenNode
      | none => expand ctx elseNode
  | TNode.TSeq nodes  => nodes.foldl (init := "") fun acc n => acc ++ expand ctx n

-- Tests ----------------------------------------------------------------

-- Simple variable substitution: "Hello, {{ name }}!" with name="World"
def helloTmpl : TNode :=
  TNode.TSeq [TNode.TText "Hello, ", TNode.TVar "name", TNode.TText "!"]

#guard expand [("name", .Str "World")] helloTmpl == "Hello, World!"

-- Loop: <ul>{% for item in items %}<li>{{ item }}</li>{% end %}</ul>
def listTmpl : TNode :=
  TNode.TSeq [
    TNode.TText "<ul>",
    TNode.TLoop "items"
      (TNode.TSeq [TNode.TText "<li>", TNode.TVar "x", TNode.TText "</li>"]),
    TNode.TText "</ul>"
  ]

def ctx : Context := [
  ("items", .List [[("x", .Str "apples")], [("x", .Str "bananas")]])
]

#guard expand ctx listTmpl == "<ul><li>apples</li><li>bananas</li></ul>"

-- Conditional
def ifTmpl : TNode :=
  TNode.TIf "show" (TNode.TText "visible") (TNode.TText "hidden")

#guard expand [("show", .Str "yes")] ifTmpl == "visible"
#guard expand [("show", .Str "")]    ifTmpl == "hidden"
#guard expand []                     ifTmpl == "hidden"
