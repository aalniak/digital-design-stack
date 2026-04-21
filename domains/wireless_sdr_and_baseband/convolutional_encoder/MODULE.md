# Convolutional Encoder

## Overview

The convolutional encoder converts an input bit stream into a redundant coded stream using shift-register memory and generator polynomials. It is a classic forward-error-correction building block for communication systems.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Legacy and lightweight communication chains often use convolutional codes for robust error correction, but the encoder's generator order, puncturing, and reset semantics must be shared exactly with the decoder. This module provides that coding stage explicitly.

## Typical Use Cases

- Encoding control or payload bits for classical communication links.
- Providing a low-complexity FEC stage in SDR baseband transmitters.
- Serving as a reusable coding primitive when modern long-block codes are unnecessary.

## Interfaces and Signal-Level Behavior

- Input side accepts uncoded bits with documented frame boundaries.
- Output side emits coded bits, optionally punctured or rate-adapted, with corresponding framing.
- Control side selects puncture pattern, reset policy, and optional tail-bit handling.

## Parameters and Configuration Knobs

- Constraint length, generator polynomials, output rate, and puncturing support.
- Bit ordering, tail-biting or flush policy, and frame-boundary semantics.
- Pipeline depth and support for several code profiles.

## Internal Architecture and Dataflow

The encoder shifts each input bit through a state memory and computes one or more output bits from the configured generator taps. Optional puncturing modifies the emitted rate according to a selected pattern. The contract should state the polynomial representation, input-bit ordering, and whether the encoder resets or tail-bites between frames.

## Clocking, Reset, and Timing Assumptions

The corresponding decoder must share the exact generator, puncturing, and framing convention, so those should remain visible in the documentation. Reset should place the encoder state in a documented all-zero or other initial condition.

## Latency, Throughput, and Resource Considerations

Encoding is lightweight and easy to sustain at high bit rates. Resource use is small and dominated by shift registers and XOR logic.

## Verification Strategy

- Compare encoded output against a reference encoder for several frame patterns and puncture modes.
- Check tail handling, reset behavior, and bit ordering.
- Verify that frame boundaries align with the documented state-reset or tail-biting policy.

## Integration Notes and Dependencies

This block usually lives near interleavers and framers, so code rate and bit order should be documented with those neighbors. Integrators should also note whether the encoded output is intended for hard or soft mapping immediately afterward.

## Edge Cases, Failure Modes, and Design Risks

- A single generator-order mismatch can break interoperability completely while the hardware appears deterministic.
- Puncturing pattern confusion can shift bit alignment for the entire frame.
- If frame-reset policy is not explicit, decoders may start from the wrong assumed state.

## Related Modules In This Domain

- bch_codec
- interleaver
- framer_deframer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Convolutional Encoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
