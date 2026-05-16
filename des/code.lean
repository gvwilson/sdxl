-- mccole: types
inductive EventKind where
  | Arrive : EventKind
  | Depart : EventKind
  deriving Repr

structure Event where
  time : Float
  kind : EventKind
  deriving Repr
-- mccole: /types

-- mccole: queue
def enqueue (e : Event) (q : List Event) : List Event :=
  match q with
  | []     => [e]
  | h :: t => if e.time <= h.time then e :: h :: t else h :: enqueue e t
-- mccole: /queue

-- mccole: state
structure State where
  serverFree : Bool
  waiting    : List Float
  log        : List String
  deriving Repr

def initState : State :=
  { serverFree := true, waiting := [], log := [] }
-- mccole: /state

-- mccole: step
def step (e : Event) (s : State) (q : List Event) (duration : Float)
    : State × List Event :=
  match e.kind with
  | .Arrive =>
    if s.serverFree then
      let depart := { time := e.time + duration, kind := .Depart }
      let msg    := s!"t={e.time}: arrive, start service"
      ({ s with serverFree := false, log := s.log ++ [msg] }, enqueue depart q)
    else
      let msg := s!"t={e.time}: arrive, queue ({s.waiting.length + 1} waiting)"
      ({ s with waiting := s.waiting ++ [e.time], log := s.log ++ [msg] }, q)
  | .Depart =>
    match s.waiting with
    | [] =>
      let msg := s!"t={e.time}: depart, server idle"
      ({ s with serverFree := true, log := s.log ++ [msg] }, q)
    | _ :: rest =>
      let depart := { time := e.time + duration, kind := .Depart }
      let msg    := s!"t={e.time}: depart, next customer starts"
      ({ s with waiting := rest, log := s.log ++ [msg] }, enqueue depart q)
-- mccole: /step

-- mccole: run
partial def simulate (q : List Event) (s : State) (duration : Float) : State :=
  match q with
  | []     => s
  | e :: rest =>
    let (s', q') := step e s rest duration
    simulate q' s' duration

def arrivals : List Event :=
  [{ time := 0, kind := .Arrive },
   { time := 2, kind := .Arrive },
   { time := 5, kind := .Arrive }]

#eval (simulate arrivals initState 3.0).log
-- ["t=0.000000: arrive, start service",
--  "t=2.000000: arrive, queue (1 waiting)",
--  "t=3.000000: depart, next customer starts",
--  "t=5.000000: arrive, queue (1 waiting)",
--  "t=6.000000: depart, next customer starts",
--  "t=9.000000: depart, server idle"]
-- mccole: /run
