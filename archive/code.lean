-- Content address = hex string of the hash
abbrev Hash = String

-- Manifest: original path → content hash
abbrev Manifest = List (String × Hash)

-- Convert a ByteArray hash (UInt64 via Lean's Hashable) to a hex string
def hashBytes (ba : ByteArray) : Hash :=
  let h : UInt64 := hash ba   -- structural hash; use SHA-256 for real archiving
  -- format as 16-char hex
  let hex := "0123456789abcdef".toList
  let digits := (List.range 16).map fun i =>
    let nibble := (h >>> (60 - i * 4).toUInt64) &&& 0xF
    hex[nibble.toNat]!
  String.mk digits

-- Pure: deduplicate a list of (path, bytes) pairs into (Manifest, blob store)
def buildManifest (files : List (String × ByteArray)) :
    Manifest × List (Hash × ByteArray) :=
  let entries := files.map fun (path, bytes) => (path, hashBytes bytes, bytes)
  let manifest := entries.map fun (path, h, _) => (path, h)
  let blobs := entries.foldl (init := []) fun acc (_, h, bytes) =>
    if acc.any (·.1 == h) then acc else acc ++ [(h, bytes)]
  (manifest, blobs)

-- IO: snapshot a list of files into an archive directory
def snapshot (files : List (String × ByteArray)) (archiveDir : String) :
    IO Manifest := do
  let (manifest, blobs) := buildManifest files
  for (h, bytes) in blobs do
    IO.FS.writeBinFile s!"{archiveDir}/{h}.bck" bytes
  return manifest

-- IO: restore files from a manifest + archive directory
def restore (manifest : Manifest) (archiveDir : String) : IO Unit := do
  for (path, h) in manifest do
    let bytes ← IO.FS.readBinFile s!"{archiveDir}/{h}.bck"
    IO.FS.writeBinFile path bytes

-- IO: snapshot all files under a directory
def snapshotDir (srcDir archiveDir : String) : IO Manifest := do
  let entries ← IO.FS.readDir srcDir
  let files ← entries.toList.filterMapM fun e => do
    if (← e.path.isDir) then return none
    let bytes ← IO.FS.readBinFile e.path.toString
    return some (e.path.toString, bytes)
  snapshot files archiveDir

-- Tests (pure core) ---------------------------------------------------

def sampleFiles : List (String × ByteArray) := [
  ("a.txt", "hello".toUTF8),
  ("b.txt", "hello".toUTF8),   -- same content as a.txt
  ("c.txt", "world".toUTF8)
]

-- Two files with identical content should produce only two blobs
#guard (buildManifest sampleFiles).2.length == 2

-- Both a.txt and b.txt map to the same hash
#guard
  let (manifest, _) := buildManifest sampleFiles
  (manifest.find? (·.1 == "a.txt")).map (·.2) ==
  (manifest.find? (·.1 == "b.txt")).map (·.2)
