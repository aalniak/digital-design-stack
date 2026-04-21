# Baseband Descrambler

## Overview

The baseband descrambler removes deterministic data whitening applied by the corresponding scrambler in a wireless or SDR protocol chain. It restores the original bit sequence after transport-oriented scrambling.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Scrambling improves statistical properties and protocol robustness, but the receiver must invert the process with the same polynomial and reset rules. This module performs that inverse operation explicitly in the baseband domain.

## Typical Use Cases

- Recovering payload bits after protocol scrambling in a receiver chain.
- Undoing whitening before FEC or frame parsing.
- Providing reusable descrambling in SDR protocol stacks.

## Interfaces and Signal-Level Behavior

- Input side accepts scrambled bits or symbols with frame or block boundaries.
- Output side emits descrambled payload bits and optional state visibility.
- Control side configures polynomial profile, reset or re-seed rules, and bypass mode.

## Parameters and Configuration Knobs

- Polynomial selection, state width, bit width per cycle, and frame-reset policy.
- Runtime profile selection, bit ordering, and optional state export for debug.
- Bypass and error-handling behavior if frame boundaries are missing.

## Internal Architecture and Dataflow

The block applies the inverse LFSR-based transform corresponding to the transmitter-side scrambler, updating its internal state as bits are consumed and generating the original payload sequence. The contract should define whether the descrambler is self-synchronous or synchronous and when state resets occur relative to frames or blocks.

## Clocking, Reset, and Timing Assumptions

The polynomial, seed, and reset convention must match the transmitted waveform exactly. Reset should place the internal state in a documented initial condition and discard partial-frame context.

## Latency, Throughput, and Resource Considerations

Descrambling is lightweight and usually sustains line-rate bit throughput with minimal logic. Resource use is small and dominated by shift-register state and XOR logic.

## Verification Strategy

- Compare output against a reference scrambler-descrambler pair across long random bit sequences.
- Check frame-boundary resets, profile switching, and bit ordering.
- Verify that self-synchronous versus synchronous modes behave as documented if both are supported.

## Integration Notes and Dependencies

This block often sits near framing and FEC decoding, so bit ordering and boundary semantics should be documented with those neighboring stages. Integrators should also note whether errors in framing invalidate the descrambler state.

## Edge Cases, Failure Modes, and Design Risks

- A wrong seed or reset point can corrupt the entire payload while leaving timing healthy.
- Bit-order mismatches are easy to miss if tests use highly regular patterns.
- If frame loss does not reset state clearly, corruption may spill into subsequent frames.

## Related Modules In This Domain

- framer_deframer
- bch_codec
- convolutional_encoder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Baseband Descrambler module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
