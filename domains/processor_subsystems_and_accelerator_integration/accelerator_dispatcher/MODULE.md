# Accelerator Dispatcher

## Overview

Accelerator Dispatcher accepts work descriptors or commands, routes them to one or more accelerators, and reports completion and fault status back to software or processor control logic. It provides centralized command dispatch for integrated acceleration subsystems.

## Domain Context

An accelerator dispatcher is the command-and-workflow coordinator between software-visible control and one or more hardware accelerators. In this domain it is the scheduler-facing block that launches work, tracks completion, and arbitrates shared accelerator resources.

## Problem Solved

As accelerators multiply inside a SoC, ad hoc control paths become hard to reason about and software integration suffers. A dedicated dispatcher makes queueing, arbitration, and completion semantics explicit.

## Typical Use Cases

- Submitting tensor or DSP jobs from a CPU to an attached accelerator.
- Arbitrating shared accelerator resources among several software clients or harts.
- Tracking job completion and fault status in an SoC with multiple engines.
- Providing one software-visible control path for a family of specialized compute units.

## Interfaces and Signal-Level Behavior

- Inputs include job descriptors, control commands, and optional completion acknowledgements from software or firmware.
- Outputs provide dispatch requests to accelerators, completion events, fault indications, and queue status.
- Control interfaces configure queue depth, priority or routing policy, and descriptor format.
- Status signals may expose queue_full, engine_busy, dispatch_error, and job_done indications.

## Parameters and Configuration Knobs

- Number of attached accelerators or dispatch targets.
- Descriptor width and queue depth.
- Priority, round-robin, or affinity-aware dispatch policy.
- Outstanding job tracking capacity and completion-order policy.

## Internal Architecture and Dataflow

The dispatcher typically contains descriptor queues, target arbitration, job-tracking state, and completion or error routing. The key contract is whether completion is in order, out of order with tags, or target-specific, because software-visible programming models and driver complexity depend on that decision.

## Clocking, Reset, and Timing Assumptions

The module assumes descriptors are well formed according to the selected accelerator protocol and that targets can backpressure or reject work in a documented way. Reset clears pending jobs according to policy, and software-visible fallout from that reset should be explicit. If several harts can submit work, access control and fairness policy should be clear.

## Latency, Throughput, and Resource Considerations

Dispatch latency, queue capacity, and completion overhead directly shape software-visible acceleration efficiency. Area is mostly control and buffer state. The main tradeoff is between a simple centralized dispatcher and the richer policy needed when several engines and several submitters compete.

## Verification Strategy

- Verify queueing, target selection, and completion semantics under representative workloads.
- Stress backpressure, target faults, and queue overflow conditions.
- Check out-of-order completion tagging if supported.
- Run end-to-end software dispatch tests with attached accelerators or accurate stubs.

## Integration Notes and Dependencies

Accelerator Dispatcher often works with Coprocessor Interface, Multicore Mailbox, performance counters, and interrupt controllers that signal completion. It should align with software driver models so descriptor and completion semantics are stable.

## Edge Cases, Failure Modes, and Design Risks

- If software expects in-order completion and hardware returns out of order, failures can be subtle and data-corrupting.
- Centralized dispatch can become a bottleneck if queueing and arbitration are undersized.
- Reset and fault behavior around in-flight jobs must be documented clearly or software recovery will be brittle.

## Related Modules In This Domain

- coprocessor_interface
- multicore_mailbox
- plic_block
- performance_counter_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Accelerator Dispatcher module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
