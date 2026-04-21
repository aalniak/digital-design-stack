# Deinterleaver

## Overview

The deinterleaver restores coded bits or symbols to their original ordering after an interleaving stage used to spread burst errors. It is the receive-path partner to the interleaver.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Interleaving improves resilience to burst errors, but only if the receiver inverts the exact same mapping. This module performs that inverse mapping with an explicit framing and memory contract.

## Typical Use Cases

- Restoring codeword ordering before channel decoding.
- Undoing bit or symbol interleaving in OFDM or coded links.
- Providing reusable inverse-permutation logic in baseband receivers.

## Interfaces and Signal-Level Behavior

- Input side accepts interleaved bits or symbols with frame boundaries.
- Output side emits reordered bits or symbols in decoder-ready order.
- Control side selects interleaving profile, frame length, and reset policy.

## Parameters and Configuration Knobs

- Block size, symbol width, interleaver profile count, and memory depth.
- Bit versus symbol interleaving mode, runtime profile selection, and frame-boundary semantics.
- Buffering style and throughput architecture.

## Internal Architecture and Dataflow

The block stores incoming items and emits them according to the inverse permutation or address schedule corresponding to the selected waveform profile. The contract should define whether output order is strictly block complete or partially streaming and how frame boundaries are enforced.

## Clocking, Reset, and Timing Assumptions

The interleaver profile must match the transmitter exactly, including any puncturing or coding layout around it. Reset should clear partial blocks and restart permutation state at a frame boundary.

## Latency, Throughput, and Resource Considerations

Deinterleaving is memory-and-address-control dominated, with cost depending on block size and throughput parallelism. Resource use is typically moderate and shaped by storage depth.

## Verification Strategy

- Compare reordered output against a software inverse interleaver for several profiles and frame sizes.
- Check frame-boundary handling, profile switching, and reset behavior.
- Verify that the output ordering matches the expectations of the downstream decoder exactly.

## Integration Notes and Dependencies

This block almost always sits next to FEC decoders and framers, so ordering and block semantics should be documented with those modules. Integrators should also state whether the deinterleaver operates on hard bits, soft bits, or symbols.

## Edge Cases, Failure Modes, and Design Risks

- A profile mismatch may still produce legal-looking output that decodes poorly rather than failing obviously.
- Block-boundary mistakes can corrupt every subsequent codeword in a stream.
- Soft-metric ordering errors are especially hard to detect with simple bit-pattern tests.

## Related Modules In This Domain

- interleaver
- bch_codec
- ldpc_codec

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Deinterleaver module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
