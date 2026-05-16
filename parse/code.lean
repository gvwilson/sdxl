-- Tokens produced by the tokenizer
inductive Token where
  | Lit    : String → Token
  | Star   : Token
  | LBrace : Token
  | RBrace : Token
  | Comma  : Token
  deriving Repr, BEq

-- Patterns (same as glob lesson)
inductive Pat where
  | Lit  : String → Pat
  | Wild : Pat
  | Seq  : Pat → Pat → Pat
  | Alt  : List Pat → Pat
  deriving Repr

-- Tokenizer ------------------------------------------------------------

private def flushLit (cur : String) (acc : List Token) : List Token :=
  if cur.isEmpty then acc else acc ++ [Token.Lit cur]

def tokenize (s : String) : List Token :=
  let (toks, cur) := s.toList.foldl (init := ([], "")) fun (acc, cur) c =>
    match c with
    | '*' => (flushLit cur acc ++ [Token.Star],   "")
    | '{' => (flushLit cur acc ++ [Token.LBrace], "")
    | '}' => (flushLit cur acc ++ [Token.RBrace], "")
    | ',' => (flushLit cur acc ++ [Token.Comma],  "")
    | _   => (acc, cur.push c)
  flushLit cur toks

-- Parser ---------------------------------------------------------------

-- Parse a comma-separated list of Lit patterns inside { }
partial def parseAlts (tokens : List Token) : List Pat × List Token :=
  match tokens with
  | Token.Lit s :: rest =>
      let (others, rest') := parseAlts' rest
      (Pat.Lit s :: others, rest')
  | _ => ([], tokens)
where
  parseAlts' : List Token → List Pat × List Token
    | Token.Comma :: Token.Lit s :: rest =>
        let (more, rest') := parseAlts' rest
        (Pat.Lit s :: more, rest')
    | ts => ([], ts)

-- Parse a sequence of pattern elements; stop at end or unmatched }
partial def parsePat (tokens : List Token) : Pat × List Token :=
  let (parts, rest) := parseElems tokens []
  match parts with
  | []     => (Pat.Lit "", rest)
  | [p]    => (p, rest)
  | p :: ps => (ps.foldl Pat.Seq p, rest)
where
  parseElems : List Token → List Pat → List Pat × List Token
    | [],                      acc => (acc, [])
    | Token.RBrace :: rest,    acc => (acc, Token.RBrace :: rest)
    | Token.Star   :: rest,    acc => parseElems rest (acc ++ [Pat.Wild])
    | Token.Lit s  :: rest,    acc => parseElems rest (acc ++ [Pat.Lit s])
    | Token.LBrace :: rest,    acc =>
        let (alts, rest') := parseAlts rest
        let rest'' := match rest' with
          | Token.RBrace :: r => r
          | r                 => r
        parseElems rest'' (acc ++ [Pat.Alt alts])
    | Token.Comma  :: rest,    acc => parseElems rest acc

def parse (s : String) : Pat := (parsePat (tokenize s)).1

-- Tests ----------------------------------------------------------------

#eval tokenize "2023-*.{pdf,txt}"
-- [Lit "2023-", Star, Lit ".", LBrace, Lit "pdf", Comma, Lit "txt", RBrace]

#eval parse "2023-*.{pdf,txt}"
-- Seq (Seq (Seq (Lit "2023-") Wild) (Lit ".")) (Alt [Lit "pdf", Lit "txt"])

#guard tokenize "ab*" == [Token.Lit "ab", Token.Star]
#guard tokenize "{x,y}" ==
  [Token.LBrace, Token.Lit "x", Token.Comma, Token.Lit "y", Token.RBrace]
