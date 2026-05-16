# Glossary

<span id="discrete-event-simulation">discrete event simulation</span>
:   A simulation technique in which the state of a system changes only at
    discrete points in time corresponding to events; between events the
    simulation clock jumps directly to the time of the next event.

<span id="event-queue">event queue</span>
:   A data structure holding future events in a discrete event simulation,
    sorted by the time at which each event will occur, so that the next event
    to process is always at the front.

<span id="simulation-clock">simulation clock</span>
:   The current time in a discrete event simulation, which advances to the
    time of each event as that event is processed rather than ticking forward
    in fixed steps.
