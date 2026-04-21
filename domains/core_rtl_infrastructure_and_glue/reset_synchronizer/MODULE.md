# Reset Synchronizer

## Overview

reset_synchronizer makes reset release safe for one local clock domain. It is a basic hygiene block for any design that uses asynchronous assertion or shared reset sources.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

If reset deasserts arbitrarily relative to a clock, downstream registers can leave reset on different edges and enter illegal intermediate states. reset_synchronizer aligns release to the local domain.

## Typical Use Cases

- Generate a safe local reset from a global reset source.
- Provide synchronized reset release for FIFOs, controllers, and processors.
- Standardize reset behavior across reusable blocks.

## Interfaces and Signal-Level Behavior

- Input is an upstream reset request or assertion source.
- Output is a domain-local reset in the chosen polarity.
- Optional status may indicate that release has completed.

## Parameters and Configuration Knobs

- STAGES sets synchronizer depth.
- ACTIVE_LOW defines polarity.
- ASYNC_ASSERT_EN allows immediate assertion.
- INIT_VALUE defines synchronizer power-up state.
- DONE_SIGNAL_EN enables release-complete indication.

## Internal Architecture and Dataflow

The common design is a short flip-flop chain held in the asserted state until the source reset deasserts. Deassertion then moves through the chain synchronously so the final stage can safely drive the local reset.

## Clocking, Reset, and Timing Assumptions

Each unrelated destination clock should have its own reset synchronizer. The module is about local release safety, not global reset distribution.

## Latency, Throughput, and Resource Considerations

Area is tiny, but placement and preservation of the synchronizer flops matter more than logic count. Release latency increases with synchronizer depth.

## Verification Strategy

- Check asynchronous assertion and synchronous release.
- Exercise short reset pulses if those are expected in the system.
- Verify output release occurs after the documented number of cycles.
- Confirm reset-done signaling aligns with final release.

## Integration Notes and Dependencies

reset_synchronizer belongs near each clock-domain boundary and should interact cleanly with reset_sequencer and clock health monitors.

## Edge Cases, Failure Modes, and Design Risks

- One synchronized reset should not be shared across unrelated clocks.
- Optimization or retiming can silently damage MTBF.
- Polarity mistakes often masquerade as random bring-up failures.

## Related Modules In This Domain

- pulse_synchronizer
- async_fifo
- reset_sequencer
- clock_fail_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Reset Synchronizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
