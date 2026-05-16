# Finding Duplicate Files

## Outline

- Naïve O(N²) approach: compare every pair of files byte-by-byte
- Better O(N) approach: hash each file's content, group files by hash; only files in
  the same group can be duplicates
- In Lean the pure core is: `group : List (String × ByteArray) → List (List String)`,
  grouping filenames by their content hash
- `ByteArray.hash` provides a fast structural hash (not cryptographic); for real use,
  replace with SHA-256 via an FFI or IO call
- The IO wrapper reads files with `IO.FS.readBinFile` and calls the pure grouping logic

## Code

[%inc code.lean %]
