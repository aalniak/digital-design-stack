# Memory Scrubber

## Overview

memory_scrubber periodically walks protected memory contents to detect, correct, and rewrite latent bit errors before they accumulate into uncorrectable failures. It is the background maintenance companion to ECC-protected storage.

## Domain Context

In the Buffering, Memory, and Data Movement domain, modules are judged by how clearly they define storage ownership, latency, burst semantics, backpressure, coherency boundaries, and error behavior. These blocks frequently sit between fast producers, slower memories, and shared interconnect.

## Problem Solved

ECC can often correct a single latent error, but if a second error accumulates before the line is revisited, correction may fail. memory_scrubber reduces that risk by actively reading and refreshing stored data.

## Typical Use Cases

- Maintain ECC-protected scratchpads or frame buffers.
- Provide proactive reliability support in long-lived systems.
- Expose corrected-error statistics and scrub coverage to safety logic.

## Interfaces and Signal-Level Behavior

- Inputs usually include start or enable, scrub address range, maintenance throttle, and reset.
- Outputs drive reads and possible corrective writes to the protected memory.
- Status may include current scrub pointer, corrected count, fatal count, and active state.

## Parameters and Configuration Knobs

- ADDRESS_WIDTH sets the scrub span.
- THROTTLE_DIVIDER limits scrub bandwidth impact.
- RANGE_MODE selects full-memory or windowed scrub.
- STAT_COUNTER_EN enables correction statistics.
- ERROR_POLICY defines response to uncorrectable lines.

## Internal Architecture and Dataflow

The scrubber is typically a low-priority walker that reads each protected location, lets ECC logic evaluate the codeword, and rewrites corrected data when needed. A useful implementation also tracks progress so software can determine whether a full region has been covered.

## Clocking, Reset, and Timing Assumptions

The target memory must provide a maintenance access path and a defined way to distinguish corrected versus fatal errors. Scrub traffic must coexist with foreground access under a documented arbitration policy.

## Latency, Throughput, and Resource Considerations

A scrubber trades background bandwidth for reliability. The main metric is coverage interval: how long it takes to revisit the full protected region at the chosen throttle. Hardware cost is small and mostly consists of address sequencing and statistics counters.

## Verification Strategy

- Inject latent single-bit and multi-bit faults across the scrub range.
- Check throttle and arbitration behavior under foreground load.
- Verify coverage progress and wraparound.
- Confirm corrected lines are rewritten and fatal lines are reported according to policy.

## Integration Notes and Dependencies

memory_scrubber usually pairs with ecc_memory_wrapper and may share a low-priority path into local RAM wrappers or caches. System safety logic should know whether scrubbing is mandatory or opportunistic.

## Edge Cases, Failure Modes, and Design Risks

- A scrubber that starves behind foreground traffic may provide little real protection.
- Corrected-versus-fatal reporting must match ECC wrapper semantics exactly.
- If rewritten data races with foreground updates, maintenance can corrupt live state.

## Related Modules In This Domain

- ecc_memory_wrapper
- dp_ram_wrapper
- sp_ram_wrapper
- frame_buffer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Memory Scrubber module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
