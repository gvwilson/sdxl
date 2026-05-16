-- Log entry: key + optional value (none = tombstone/deleted)
abbrev LogEntry := String × Option String
abbrev Log = List LogEntry

-- Pure in-memory database operations --------------------------------

-- Append a record
def dbSet (log : Log) (key val : String) : Log :=
  log ++ [(key, some val)]

def dbDel (log : Log) (key : String) : Log :=
  log ++ [(key, none)]

-- Scan newest-first; return first match
def dbGet (log : Log) (key : String) : Option String :=
  log.reverse.findSome? fun (k, v) =>
    if k == key then some v else none
  |>.join   -- Option (Option String) → Option String

-- Compact: keep only the latest entry per key
def dbCompact (log : Log) : Log :=
  let (_, kept) := log.reverse.foldl (init := ([], [])) fun (seen, acc) (k, v) =>
    if seen.contains k then (seen, acc)
    else (k :: seen, (k, v) :: acc)
  kept   -- already in original (newest-last) order

-- File-backed operations ---------------------------------------------

-- Serialize one entry as "key\tvalue\n" or "key\t\n" for tombstone
def serializeEntry (k : String) (v : Option String) : String :=
  s!"{k}\t{v.getD ""}\n"

def deserializeEntry (line : String) : Option LogEntry :=
  match line.splitOn "\t" with
  | [k, v] => some (k, if v.isEmpty then none else some v)
  | _       => none

-- Append one entry to a file
def appendEntry (path key : String) (val : Option String) : IO Unit := do
  let h ← IO.FS.Handle.mk path IO.FS.Mode.append
  h.putStr (serializeEntry key val)
  h.flush

-- Read entire log from file
def readLog (path : String) : IO Log := do
  let text ← IO.FS.readFile path
  return text.splitOn "\n" |>.filterMap deserializeEntry

-- Tests ---------------------------------------------------------------

-- Set and get
#guard dbGet (dbSet [] "x" "1") "x" == some "1"

-- Latest write wins
#guard dbGet (dbSet (dbSet [] "x" "1") "x" "2") "x" == some "2"

-- Tombstone
#guard dbGet (dbDel (dbSet [] "x" "1") "x") "x" == none

-- Compact reduces redundant entries
def messyLog : Log := [("a","1"), ("b","1"), ("a","2"), ("b", none)]
#guard dbCompact messyLog == [("a", "2"), ("b", none)]
