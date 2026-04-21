# Flash ECC Block

## Overview

The flash ECC block generates and checks error-correcting codes tailored to flash-memory error modes so raw pages can be stored and recovered with controlled reliability. It is a core reliability primitive for raw NAND and other media where bit errors are expected, not exceptional.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

Flash arrays suffer disturb, wear, and retention errors that accumulate as the media ages. Without an explicit ECC layer, raw page reads become progressively unreliable. This module inserts a clear encode and decode boundary around page data so storage pipelines can detect or correct faults and retire media when the error budget is exceeded.

## Typical Use Cases

- Protecting raw NAND page reads and writes in custom flash controllers.
- Providing correction statistics to wear-leveling or bad-block management layers.
- Supporting boot or metadata regions that require stronger integrity guarantees than unmanaged raw storage offers.

## Interfaces and Signal-Level Behavior

- Write path accepts page or chunk data and emits encoded parity or a widened protected payload format.
- Read path consumes raw data plus stored ECC information and returns corrected data, syndrome details, and error classification.
- Status outputs expose corrected-bit counts, uncorrectable faults, and possibly per-page health telemetry.

## Parameters and Configuration Knobs

- ECC scheme, chunk size, correction strength, spare-area placement, and pipeline depth.
- Support for soft-decision assistance, syndrome exposure, and partial-page operations if applicable.
- Metadata format and whether parity is stored interleaved with data or in a separate spare region.

## Internal Architecture and Dataflow

The block usually segments each page into protected chunks, computes parity on write, and on read derives a syndrome that either corrects the data or flags failure. Different flash technologies demand different code strengths, so the module contract should emphasize what error model it targets rather than pretending one ECC profile fits all media. Correction results often feed higher policy layers that decide whether data should be refreshed or blocks retired.

## Clocking, Reset, and Timing Assumptions

The ECC engine assumes the surrounding controller presents data in the same chunking and bit order used when the parity was generated. Reset must not lose the interpretation of in-flight page boundaries or spare-area placement rules.

## Latency, Throughput, and Resource Considerations

Page-oriented ECC can be heavily pipelined, but correction latency still matters because it sits on every read path. Area and timing scale with correction strength and chosen code family.

## Verification Strategy

- Inject correctable and uncorrectable bit patterns across supported chunk sizes and page layouts.
- Check spare-area placement and page-boundary handling so parity is matched to the right data region.
- Verify corrected-bit counts and uncorrectable flags are surfaced accurately to management logic.

## Integration Notes and Dependencies

This block works closely with raw flash controllers, spare-area layout definitions, and bad-block policy. Integration should define how ECC statistics influence refresh, remap, or retirement decisions and whether software can inspect per-page correction margins.

## Edge Cases, Failure Modes, and Design Risks

- A mismatch in chunk boundaries or spare-area placement can make every decode fail despite valid stored parity.
- Underestimating media error rate leads to choosing a correction strength that ages out too quickly.
- If corrected-error telemetry is ignored, the system loses early warning before failures become uncorrectable.

## Related Modules In This Domain

- nand_flash_controller
- bad_block_manager
- emmc_host_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Flash ECC Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
