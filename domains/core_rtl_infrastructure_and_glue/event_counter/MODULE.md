# Event Counter

## Overview

event_counter counts qualified occurrences of a local event and exposes the result to software, monitoring logic, or threshold logic. It is the standard statistics and observability primitive for reusable IP.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

One-off counters often disagree on wrap policy, clear timing, threshold behavior, and snapshot semantics. event_counter makes those rules explicit and reusable.

## Typical Use Cases

- Count completions, drops, faults, or interrupts.
- Expose software-readable performance statistics.
- Drive threshold-triggered status or alarms.

## Interfaces and Signal-Level Behavior

- Inputs usually include event pulse, enable, clear, and optional snapshot or freeze.
- Outputs include count value and optional overflow or threshold-hit flags.
- A register-facing wrapper may expose live and snapshot values separately.

## Parameters and Configuration Knobs

- COUNT_WIDTH sets numeric range.
- SATURATE selects wrap or clip behavior.
- THRESHOLD_EN adds compare outputs.
- SNAPSHOT_EN adds a latched readout path.
- CLEAR_PRIORITY defines how clear interacts with an event on the same cycle.

## Internal Architecture and Dataflow

The block is a counter with optional enable gating, snapshot storage, and compare logic. The key design choice is how software-facing visibility works without perturbing live counting.

## Clocking, Reset, and Timing Assumptions

The event must already be synchronous to the local clock. Reset should define the count and any sticky status flags. If the event is asynchronous, another CDC primitive must be used first.

## Latency, Throughput, and Resource Considerations

The live increment path is usually one event per cycle. Wider counts and threshold logic can lengthen the critical path, so compare logic may need pipelining in very fast designs.

## Verification Strategy

- Check wrap and saturate modes separately.
- Exercise clear, snapshot, and threshold crossings.
- Verify simultaneous clear and count according to the documented priority.
- Stress long runs to catch silent off-by-one errors.

## Integration Notes and Dependencies

event_counter pairs naturally with timer_block, interrupt_controller, CSR logic, and fault monitors. Keeping counts out of ad hoc logic improves testability and consistency.

## Edge Cases, Failure Modes, and Design Risks

- Asynchronous events cannot be counted safely without prior synchronization.
- Ambiguous clear-versus-count policy causes software discrepancies.
- Very wide counters can become accidental timing bottlenecks.

## Related Modules In This Domain

- free_running_counter
- timer_block
- interrupt_controller
- pulse_synchronizer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Event Counter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
