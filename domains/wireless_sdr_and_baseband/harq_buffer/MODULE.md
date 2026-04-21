# HARQ Buffer

## Overview

The HARQ buffer stores soft or coded information across retransmissions so hybrid ARQ combining can improve decode success on later attempts. It is a temporal memory block for coded baseband systems rather than a simple FIFO.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Hybrid ARQ depends on combining information from several transmission attempts, but that requires persistent, indexed storage of soft metrics or coded bits across protocol events. This module provides that memory and bookkeeping layer.

## Typical Use Cases

- Supporting soft combining across retransmissions in wireless receivers.
- Buffering coded blocks by HARQ process and redundancy version.
- Providing reusable retransmission-memory infrastructure in baseband systems.

## Interfaces and Signal-Level Behavior

- Input side accepts decoded or partially decoded soft information plus process identifiers and redundancy metadata.
- Output side emits combined or retrieved soft information for a later decode attempt.
- Control side configures process count, buffer management, and clear or release policy.

## Parameters and Configuration Knobs

- Process count, buffer depth, soft-metric width, and codeword size.
- Redundancy-version handling, combine mode, and timeout or discard policy.
- Memory organization and runtime process reset support.

## Internal Architecture and Dataflow

The buffer indexes incoming soft information by HARQ process and transmission context, stores or combines it with prior attempts, and later returns the accumulated result to a decoder when another retransmission arrives. The contract should specify whether combining happens on write, on read, or in a separate stage, and how process IDs map to stored state.

## Clocking, Reset, and Timing Assumptions

Higher-layer scheduling must supply consistent process and redundancy metadata, because the buffer itself cannot infer protocol sequencing. Reset should clear all process state or a documented subset explicitly.

## Latency, Throughput, and Resource Considerations

The block is memory heavy and may carry wide soft metrics, but its arithmetic is usually simple combining rather than complex decoding. Resource use scales with process count, block size, and soft-metric precision.

## Verification Strategy

- Check process indexing, combine behavior, and release or timeout policy against a protocol reference.
- Verify reset, partial-process clearing, and buffer-overwrite prevention.
- Confirm that retrieved soft information matches the expected redundancy-version alignment.

## Integration Notes and Dependencies

This block usually sits adjacent to FEC decoders and scheduler logic, so process-ID semantics should be documented with those neighbors. Integrators should also note whether buffers carry LLRs, hard bits, or another metric type.

## Edge Cases, Failure Modes, and Design Risks

- A process-index mismatch can combine unrelated retransmissions and poison decoding.
- If combine semantics are unclear, decoder performance may degrade in subtle, nonbinary ways.
- Buffer release policy that lags protocol state can waste memory or create stale reuse.

## Related Modules In This Domain

- ldpc_codec
- bch_codec
- framer_deframer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the HARQ Buffer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
