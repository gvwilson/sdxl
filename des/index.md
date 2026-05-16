# A Discrete Event Simulator

## Modeling Time as Events

-   A [%g discrete-event-simulation "discrete event simulation" %] models a
    system as a series of events, each happening at a specific point in time
-   Between events, nothing changes—the [%g simulation-clock "simulation clock" %]
    jumps directly from one event to the next rather than ticking forward in
    fixed steps
-   Representing events as data rather than as running coroutines is the key
    insight: it lets a single loop drive the entire simulation without any
    shared mutable state or thread synchronization
-   A single-server queue is the simplest non-trivial example: customers arrive,
    wait if the server is busy, get served, and leave
-   Two things can happen in this system, so `EventKind` has two constructors;
    each `Event` pairs a kind with the time at which it occurs

[%inc code.lean mark=types %]

## Keeping Events in Order

-   The [%g event-queue "event queue" %] is a `List Event` sorted by time,
    smallest first, so the next event to process is always at the front
-   `enqueue` walks the list and inserts the new event before the first
    existing event whose time is later
-   Lean proves this terminates automatically because each recursive call
    operates on a structurally smaller list
-   Inserting in order is simpler than appending and re-sorting, and it keeps
    the simulation loop free of sorting logic

[%inc code.lean mark=queue %]

## Tracking State

-   The simulation needs to know whether the server is free and which customers
    are waiting; bundling this into a `State` record keeps `step` a pure
    function with no hidden side effects
-   `serverFree` is `true` when the server can take a new customer immediately
-   `waiting` records the arrival times of customers who are queued; its length
    is the current queue depth
-   `log` accumulates a human-readable history of events so the caller can
    inspect what happened after the simulation ends

[%inc code.lean mark=state %]

## Processing Events

-   `step` takes one event off the front of the queue and returns an updated
    state and a new queue, possibly with a freshly scheduled event inserted
-   When a customer arrives and the server is free, `step` schedules a
    departure at `e.time + duration` and marks the server busy
-   When a customer arrives and the server is busy, `step` appends the arrival
    time to `waiting` and leaves the queue unchanged
-   When a customer departs and someone is waiting, `step` immediately starts
    serving the next customer by scheduling another departure
-   When a customer departs and no one is waiting, `step` marks the server free
    and adds nothing to the queue

[%inc code.lean mark=step %]

## Running the Loop

-   `simulate` calls `step` repeatedly until the queue is empty, threading the
    state through each call
-   Lean cannot prove `simulate` terminates because each call to `step` may add
    a new event, so we mark it `partial`; in practice the queue empties once
    the last customer departs
-   Three customers arriving at times 0, 2, and 5 with a service duration of 3
    produce six log entries: the second and third customers each wait briefly
    before the server is free
-   This design follows the event-queue approach described in [%b Banks2014 %],
    which is the standard reference on discrete event simulation

[%inc code.lean mark=run %]

## Exercises

### Adding a Second Server

-   Replace `serverFree : Bool` with `serversAvailable : Nat` to model a pool
    of servers
-   Update `step` so an arriving customer takes one server if any are available
    and joins the wait queue otherwise
-   Test with two servers and the same three arrivals and verify that no
    customer ever has to wait

### Tracking Wait Times

-   Store each customer's arrival time when they join `waiting` instead of
    discarding it
-   When a depart event starts the next customer, compute how long that customer
    waited and append it to a `List Float` in `State`
-   Run the simulation and report the longest wait across all customers

### Stopping Early

-   Add a `limit : Float` parameter to `simulate`
-   Stop processing events once `e.time > limit` and return the state at that
    point along with the unprocessed queue
-   Run the three-customer example with a limit of 4 and check which events are
    left in the queue

### Turning Customers Away

-   Add a `capacity : Nat` parameter to `step` representing the maximum number
    of customers allowed to wait
-   Add a `turnedAway : Nat` counter to `State`
-   When a customer arrives and the queue is already at capacity, increment
    `turnedAway` instead of adding them to `waiting`
