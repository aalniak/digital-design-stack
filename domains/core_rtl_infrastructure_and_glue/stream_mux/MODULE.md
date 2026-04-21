# Stream Mux

## Overview

stream_mux merges several ingress streams onto one egress stream under a documented arbitration policy. It is the standard fan-in primitive for stream composition.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Merging streams safely requires correct arbitration, data selection, and ready routing. Ad hoc mux logic often mishandles one of those three. stream_mux makes the combined policy reusable and testable.

## Typical Use Cases

- Merge multiple producers onto one shared processing path.
- Concentrate several control streams onto a single output.
- Select among candidate data sources under fixed-priority or fair scheduling.

## Interfaces and Signal-Level Behavior

- Each input is a stream interface with optional sidebands.
- The output uses the same protocol and may also emit source ID.
- Arbitration can be fixed priority, round robin, or externally driven.

## Parameters and Configuration Knobs

- NUM_INPUTS sets fan-in.
- ARBITRATION_MODE selects priority policy.
- HOLD_UNTIL_LAST preserves packet atomicity.
- SOURCE_ID_EN adds provenance information.
- PIPELINE_ARB_EN allows timing staging around arbitration.

## Internal Architecture and Dataflow

The block combines an arbiter, a data multiplexer, and backpressure routing. For packet traffic, it often latches the winning input until the transaction ends.

## Clocking, Reset, and Timing Assumptions

All ports share one clock. Reset clears any held selection. If packet mode is supported, packet-boundary sidebands must be present and trusted.

## Latency, Throughput, and Resource Considerations

A well-designed mux can sustain one output beat per cycle, but arbitration and ready routing may become the dominant timing path at large fan-in.

## Verification Strategy

- Check that only the granted input observes ready.
- Verify arbitration policy with long randomized traffic.
- For packet mode, ensure a packet does not switch sources mid-flight.
- Stress downstream stalls during changing request patterns.

## Integration Notes and Dependencies

stream_mux works closely with priority or round-robin arbiters, packet FIFOs, and downstream consumers that may want source tags. It is a core composition block for reusable dataflow.

## Edge Cases, Failure Modes, and Design Risks

- Ready routing bugs often appear only under simultaneous grant changes and stalls.
- Packet atomicity must not depend on undocumented external behavior.
- Large muxes can become timing bottlenecks quickly.

## Related Modules In This Domain

- stream_demux
- priority_arbiter
- round_robin_arbiter
- packet_fifo

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Stream Mux module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
