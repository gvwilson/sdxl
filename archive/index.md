# A File Archiver

## Outline

- Hash each file's bytes to produce a content address (like Git's object store)
- A `Manifest` maps original file paths to their content hashes
- `snapshot` reads a directory, hashes every file, writes each unique blob to
  `<hash>.bck`, and records the manifest
- `restore` reads a manifest and copies the blobs back to their original names
- Pure core: `Manifest` operations, hash computation, de-duplication
- IO layer: `IO.FS.readBinFile`, `IO.FS.writeBinFile`, `IO.FS.readDir`

## Code

[%inc code.lean %]
