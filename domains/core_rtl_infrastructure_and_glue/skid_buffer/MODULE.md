# Skid Buffer

## Overview

skid_buffer is a tiny elastic buffer for ready-valid interfaces that captures the extra beat already launched when backpressure arrives too late. It is a timing-relief primitive with minimal added depth.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Registering ready directly can lose data because the producer may send one more beat before seeing the stall. skid_buffer stores that beat so timing can be improved without breaking lossless flow control.

## Typical Use Cases

- Break a long ready path at a high-speed boundary.
- Absorb one or two in-flight beats during short stalls.
- Provide minimal elasticity in front of a timing-critical consumer.

## Interfaces and Signal-Level Behavior

- Externally it looks like a standard valid-ready channel.
- Internally it captures one or a few beats when a stall arrives late.
- Some variants expose occupancy or bypass state for debug.

## Parameters and Configuration Knobs

- DATA_WIDTH sizes payload.
- DEPTH chooses one or a few spare entries.
- REGISTER_READY selects backward-path timing style.
- SIDEBAND_WIDTH carries associated control fields.
- LOW_LATENCY_MODE keeps the empty path lightweight.

## Internal Architecture and Dataflow

The classic design uses a pass-through path plus a backup register. Slightly deeper versions generalize this into a tiny occupancy structure. The central requirement is correct handling of the first stall cycle.

## Clocking, Reset, and Timing Assumptions

The protocol is synchronous ready-valid. Reset clears stored beats. Sidebands must remain aligned with payload through every occupancy state.

## Latency, Throughput, and Resource Considerations

The empty-path latency is usually zero or one cycle depending on style, while throughput remains one beat per cycle in steady state. Cost is lower than a FIFO because the depth is intentionally tiny.

## Verification Strategy

- Exercise the exact cycle where ready drops while valid remains high.
- Check repeated short stalls and resumes.
- Verify no beat duplication or loss with sidebands present.
- Compare occupied and bypass latency against the documented contract.

## Integration Notes and Dependencies

skid_buffer sits naturally before register slices, converters, muxes, and arithmetic pipelines with long ready paths. It should not be used where actual burst absorption is needed.

## Edge Cases, Failure Modes, and Design Risks

- The first-stall cycle is the classic bug point.
- Misusing skid_buffer as a deep queue leads to burst-loss surprises.
- Partial protocol registration can create timing relief while breaking correctness.

## Related Modules In This Domain

- register_slice
- stream_fifo
- stream_mux
- width_converter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Skid Buffer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
