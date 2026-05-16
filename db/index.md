# A Database

## Outline

- Log-structured key-value store: every write appends a new `(key, value)` record
- `get` scans the log from newest to oldest, returning the first match (no deletion
  of old entries; the newest version wins)
- `delete` appends a tombstone `(key, none)` record
- In-memory model: the log is a `List (String × Option String)`
- File-backed model: serialize each record as a line and append to a file using
  `IO.FS.Handle` opened in append mode
- `compact` rewrites the log keeping only the most recent record per key

## Code

[%inc code.lean %]
