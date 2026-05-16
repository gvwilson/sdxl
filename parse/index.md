# Parsing Text

## Outline

- Stage 1 (tokenizer): scan a glob string character by character into a `Token` list;
  special chars `*`, `{`, `}`, `,` each become their own token; runs of other chars
  become a single `Lit` token
- Stage 2 (parser): consume tokens left-to-right, producing the `Pat` tree from the
  `glob` lesson; `{a,b}` becomes `Alt [Lit "a", Lit "b"]`; sequences are folded into
  `Seq` nodes
- Parser returns `(Pat, remaining tokens)` so each sub-parser is composable

## Code

[%inc code.lean %]
