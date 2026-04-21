# 8b/10b Encoder

## Overview

The 8b/10b encoder maps payload and control bytes into balanced 10-bit transmission characters with bounded run length and explicit control-symbol support. It is a classic building block for legacy serial links, control-plane lanes, and transceiver protocols that rely on comma symbols and disparity tracking.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Many serial links need enough transitions for clock recovery and a way to reserve special characters for alignment and link control. Raw bytes cannot provide those guarantees consistently. This module performs the standard 8b/10b transform so line-side logic can count on disparity management and comma-capable control codes.

## Typical Use Cases

- Driving older high-speed serial links or auxiliary channels that expect 8b/10b symbols.
- Generating ordered sets, commas, or protocol-specific control characters for bring-up and alignment.
- Pairing with a decoder in test infrastructure where symbol-level visibility matters.

## Interfaces and Signal-Level Behavior

- Input side takes one or more bytes plus a flag that distinguishes data bytes from K-code control bytes.
- Output side emits 10-bit symbols and usually exposes running disparity for monitoring.
- Error outputs flag illegal K-code requests or unsupported character combinations.

## Parameters and Configuration Knobs

- Number of bytes processed per cycle, reset disparity state, and optional pipelining.
- Allowed control-code subset and whether the implementation exposes disparity state externally.
- Packing format when several encoded symbols are emitted in one wider cycle.

## Internal Architecture and Dataflow

The encoder decomposes each input byte into 5b/6b and 3b/4b subtransforms, choosing among alternate encodings based on current running disparity and whether the symbol is data or control. Multi-byte versions parallelize that mapping while updating disparity across the emitted symbol sequence in order. The result is a link-friendly symbol stream with bounded run length and protocol-visible control characters.

## Clocking, Reset, and Timing Assumptions

The module assumes upstream logic does not request control symbols outside the legal set. Reset must establish a documented initial disparity so the first emitted symbol sequence is reproducible for link training and verification.

## Latency, Throughput, and Resource Considerations

8b/10b has significant bandwidth overhead compared with raw bytes or 64b/66b, but the logic is mature and predictable. Resource use scales with symbols processed per cycle, and timing is usually dominated by disparity-dependent lookup logic.

## Verification Strategy

- Compare emitted symbols against canonical 8b/10b tables for both data and control codes.
- Track running disparity across long random sequences and verify it never diverges from the reference model.
- Exercise illegal control requests and reset sequences to confirm deterministic startup behavior.

## Integration Notes and Dependencies

This encoder is often paired with comma-alignment receivers, SERDES wrappers, or protocol-specific ordered-set generators. Designers should document which layer owns character framing and whether downstream gearboxes preserve symbol boundaries exactly.

## Edge Cases, Failure Modes, and Design Risks

- A wrong initial disparity can make a compliant encoder fail interoperability despite looking close in simulation.
- Packing several symbols per cycle without preserving order can break downstream disparity assumptions.
- Control-code filtering must be explicit or user payload may accidentally request reserved characters.

## Related Modules In This Domain

- encoder_64b66b
- pcs_wrapper
- aurora_style_link

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the 8b/10b Encoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
