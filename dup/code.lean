-- Pure core: group names by hash of associated data -----------------

def groupBy {α β : Type} [BEq β] [Hashable β]
    (items : List (String × α)) (key : α → β) : List (List String) :=
  let pairs := items.map fun (name, content) => (key content, name)
  let allKeys := pairs.map (·.1) |>.eraseDups
  allKeys.filterMap fun k =>
    let group := pairs.filterMap fun (k', name) =>
      if k' == k then some name else none
    if group.length > 1 then some group else none

-- Duplicate detection on in-memory byte arrays
def findDuplicates (files : List (String × ByteArray)) : List (List String) :=
  groupBy files (fun ba => hash ba)

-- IO wrapper: read files from disk and find duplicates ---------------

def findDuplicateFiles (paths : List String) : IO (List (List String)) := do
  let contents ← paths.mapM fun p => do
    let bytes ← IO.FS.readBinFile p
    return (p, bytes)
  return findDuplicates contents

-- Tests on in-memory data --------------------------------------------

def mkBytes (s : String) : ByteArray := s.toUTF8

#guard
  findDuplicates [("a", mkBytes "hello"), ("b", mkBytes "hello"), ("c", mkBytes "world")]
    == [["a", "b"]]

#guard
  findDuplicates [("x", mkBytes "foo"), ("y", mkBytes "bar")]
    == []

-- Complexity note:
-- Naïve: O(N²) comparisons of full content
-- Hash-based: O(N) hashes + O(G) per group where G is group size
-- When all files differ: O(N) total  (no groups to compare further)
