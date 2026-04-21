# Interleaver

## Overview

The interleaver permutes bits or symbols so burst errors are spread across a codeword in a pattern the decoder can handle more effectively. It is a transmit-path robustness stage paired with the deinterleaver.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Burst errors can overwhelm decoders even when average error rate is acceptable. Interleaving distributes those bursts, but only if the exact permutation is shared with the receiver. This module provides that permutation stage with explicit block semantics.

## Typical Use Cases

- Preparing coded bits for burst-error resilience in wireless links.
- Applying standardized interleaving before modulation or framing.
- Providing reusable permutation logic in baseband transmitters.

## Interfaces and Signal-Level Behavior

- Input side accepts bits or symbols grouped into interleaver blocks.
- Output side emits the permuted stream according to the selected profile.
- Control side configures interleaver profile, frame size, and reset or flush policy.

## Parameters and Configuration Knobs

- Block size, element width, interleaver profile count, and throughput style.
- Bit versus symbol interleaving mode, runtime profile selection, and frame-boundary semantics.
- Memory depth and output ordering guarantees.

## Internal Architecture and Dataflow

The block stores incoming elements and then emits them according to the programmed permutation or address schedule. Depending on profile, it may be strictly block-based or partially streaming. The documentation should define when an interleaved block is considered complete and whether any padding or shortening rules apply.

## Clocking, Reset, and Timing Assumptions

The transmitter and receiver must share the same profile and block interpretation exactly. Reset should clear partial interleaver state and restart at a defined frame boundary.

## Latency, Throughput, and Resource Considerations

Interleaving is memory-and-address-control dominated with moderate resource use set by block size and throughput parallelism. Arithmetic cost is negligible compared with storage control.

## Verification Strategy

- Compare permuted output against a reference interleaver for several profiles and block sizes.
- Check frame-boundary handling, profile changes, and reset behavior.
- Verify compatibility with the expected deinterleaver ordering.

## Integration Notes and Dependencies

This block typically sits between coding and mapping or framing, so its element ordering should be documented with those neighboring stages. Integrators should also note whether soft metrics or only hard bits are in scope.

## Edge Cases, Failure Modes, and Design Risks

- A permutation-profile mismatch will preserve data rate while destroying decoder performance.
- Partial-frame or padded-block semantics that are unclear can corrupt block boundaries subtly.
- Runtime profile switches without synchronization can poison adjacent frames.

## Related Modules In This Domain

- deinterleaver
- convolutional_encoder
- ldpc_codec

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Interleaver module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
