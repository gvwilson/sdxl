-- HTML node tree
abbrev Attrs := List (String × String)

inductive Node where
  | Text    : String → Node
  | Element : String → Attrs → List Node → Node
  deriving Repr

-- Visitor record: callbacks invoked on enter and leave
structure Visitor (α : Type) where
  onEnter : String → Attrs → α → α
  onLeave : String → α → α
  onText  : String → α → α

-- Walk the tree, threading accumulator through callbacks
def walk {α} (v : Visitor α) (acc : α) : Node → α
  | Node.Text t        => v.onText t acc
  | Node.Element tag attrs children =>
      let acc' := v.onEnter tag attrs acc
      let acc'' := children.foldl (walk v) acc'
      v.onLeave tag acc''

-- Helper: find attribute value
def getAttr (attrs : Attrs) (name : String) : Option String :=
  (attrs.find? (·.1 == name)).map (·.2)

-- Validator: collect error messages
abbrev Errors := List String

def noopVisitor : Visitor Errors :=
  { onEnter := fun _ _ e => e, onLeave := fun _ e => e, onText := fun _ e => e }

-- Check <img> elements have alt attribute
def imgAltVisitor : Visitor Errors :=
  { noopVisitor with
    onEnter := fun tag attrs errs =>
      if tag == "img" && getAttr attrs "alt" == none
      then errs ++ ["img missing alt"]
      else errs }

-- Check <a> elements have href attribute
def linkHrefVisitor : Visitor Errors :=
  { noopVisitor with
    onEnter := fun tag attrs errs =>
      if tag == "a" && getAttr attrs "href" == none
      then errs ++ ["a missing href"]
      else errs }

-- Compose validators by running both over the tree
def validate (doc : Node) : Errors :=
  walk imgAltVisitor [] doc ++ walk linkHrefVisitor [] doc

-- Tests ----------------------------------------------------------------

def goodDoc : Node :=
  Node.Element "html" [] [
    Node.Element "body" [] [
      Node.Element "img" [("src", "pic.jpg"), ("alt", "a picture")] [],
      Node.Element "a"   [("href", "https://example.com")] [Node.Text "click"]
    ]
  ]

def badDoc : Node :=
  Node.Element "html" [] [
    Node.Element "body" [] [
      Node.Element "img" [("src", "pic.jpg")] [],          -- missing alt
      Node.Element "a"   [] [Node.Text "click"]             -- missing href
    ]
  ]

#guard validate goodDoc == []
#guard validate badDoc == ["img missing alt", "a missing href"]
