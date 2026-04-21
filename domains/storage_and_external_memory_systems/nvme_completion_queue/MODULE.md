# NVMe Completion Queue

## Overview

The NVMe completion queue module manages completion entries returned to host software after NVMe commands retire. It is responsible for coherent queue-head progression, status formatting, and notification semantics on the completion side of an NVMe-style interface.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

Submission and execution logic are only half of an NVMe path. Software also needs a disciplined completion queue with phase tagging, head or tail semantics, status fields, and interrupt signaling. This module centralizes that retirement interface so command executors can publish results without each one learning host-facing queue rules.

## Typical Use Cases

- Retiring storage or accelerator commands in an NVMe-like endpoint implementation.
- Providing host-software visible completion semantics for queue-based command engines.
- Supporting research NVMe devices where command execution logic is custom but queue behavior should remain familiar.

## Interfaces and Signal-Level Behavior

- Producer side accepts command identifier, status code, queue context, and optional result metadata from backend executors.
- Host-facing side writes completion entries into memory-visible queue storage and updates doorbells or interrupt sources.
- Control side tracks queue phase, head or tail ownership, and software-consumed progress.

## Parameters and Configuration Knobs

- Queue depth, completion entry format options, interrupt coalescing support, and queue count.
- Doorbell update policy, memory interface width, and support for multiple outstanding producers.
- Optional metadata fields such as command-specific result values or phase-tracking style.

## Internal Architecture and Dataflow

The module normally buffers completed command metadata, formats an NVMe-style completion entry, writes it to the correct host-visible queue slot, toggles phase when wrapping, and triggers notification when appropriate. It decouples backend completion timing from software-visible queue semantics so the execution path can stay focused on data movement or media access.

## Clocking, Reset, and Timing Assumptions

Correct operation depends on a clear contract with the submission side regarding command identifiers and queue affinity. Reset and controller reset must reinitialize phase and head or tail state exactly as software expects, or queues become unreadable.

## Latency, Throughput, and Resource Considerations

Completion traffic is lighter than payload movement, but burst completion handling still matters when many commands retire together. Area cost is modest and mainly queue bookkeeping plus host-memory write plumbing.

## Verification Strategy

- Verify entry formatting, phase toggling, queue wraparound, and software-consumed progress handling.
- Check coalesced notification behavior and multiple-producer completion ordering.
- Exercise reset, queue exhaustion, and host-late-consumption scenarios.

## Integration Notes and Dependencies

This block pairs directly with submission queues, command schedulers, and host-memory interfaces. Integration should define how queue memory is addressed, how interrupts are triggered or masked, and how error completions map to backend fault categories.

## Edge Cases, Failure Modes, and Design Risks

- Incorrect phase handling can make a full queue look empty or vice versa to the host.
- If completion entries can be written before payload persistence is guaranteed, software may observe false completion.
- Multiple completion producers need careful arbitration to avoid duplicated or lost entries.

## Related Modules In This Domain

- nvme_submission_queue
- storage_dma_engine
- reorder_buffer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the NVMe Completion Queue module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
