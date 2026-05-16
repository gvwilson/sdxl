# Generating Documentation

## Outline

- Represent a source file as a list of `Decl` values: `DFunc`, `DStruct`, `DModule`
- Each `Decl` carries an optional doc comment string
- `extract` walks the declaration list and collects `DocEntry` records (kind, name,
  doc string)
- `renderMarkdown` turns the entries into a Markdown string with headings per kind
- The IO layer reads a `.lean` file, strips `--` doc comments attached to `def`/
  `structure` declarations, builds the `Decl` list, then writes the rendered output

## Code

[%inc code.lean %]
