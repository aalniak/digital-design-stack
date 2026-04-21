# Equalizer Core

## Overview

The equalizer core compensates channel-induced amplitude and phase distortion so received symbols are restored closer to their transmitted constellation points. It is a central receive-path correction block in many communication systems.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Wireless and wired channels distort symbols, and without equalization the demapper sees smeared or rotated constellations. This module provides the correction stage, but only if channel estimates, update timing, and output semantics are explicit.

## Typical Use Cases

- Equalizing single-carrier or OFDM subcarrier symbols in a receiver.
- Compensating multipath or frequency-selective channel distortion.
- Providing reusable channel inversion or MMSE-style correction in baseband systems.

## Interfaces and Signal-Level Behavior

- Input side accepts received symbols and optional channel-estimate metadata.
- Output side emits equalized symbols plus optional error or gain telemetry.
- Control side configures equalizer mode, coefficient updates, and bypass or freeze behavior.

## Parameters and Configuration Knobs

- Symbol precision, coefficient width, equalizer mode, and channel-estimate format.
- Single-tap versus multi-tap support, update cadence, and scaling or normalization policy.
- Runtime mode selection and optional decision-directed adaptation support.

## Internal Architecture and Dataflow

The core applies channel-dependent complex gains or filter taps to the received symbols, often using channel estimates from a dedicated estimator and optionally decision-directed updates. In OFDM systems this may be one tap per subcarrier; in time-domain systems it may be a longer filter. The contract should define the exact correction convention and whether outputs are normalized or still carry residual gain.

## Clocking, Reset, and Timing Assumptions

The incoming channel estimate must match the equalizer mode and symbol ordering exactly, and the residual distortion must lie within the documented correction model. Reset should clear coefficient state and validity flags predictably.

## Latency, Throughput, and Resource Considerations

Equalization is moderate in cost and often runs at symbol or subcarrier rate. Resource use depends strongly on tap count, precision, and whether adaptation is included.

## Verification Strategy

- Compare equalized symbols against a reference equalizer on known channel models and estimation quality.
- Check scaling, bypass, and coefficient-update behavior.
- Verify integration with channel-estimate validity and reset transitions.

## Integration Notes and Dependencies

This block usually sits between channel estimation and carrier recovery or demapping, depending on architecture, so all three should share a documented symbol convention. Integrators should also note whether the equalizer is intended to remove most amplitude variation or merely improve demapper margin.

## Edge Cases, Failure Modes, and Design Risks

- Applying the wrong channel estimate ordering can make the equalizer degrade rather than improve performance.
- Scaling that is not explicit can create hidden clipping or weak-symbol underutilization.
- Residual CFO or phase noise may make the equalizer appear unstable if loop interactions are not documented.

## Related Modules In This Domain

- channel_estimator
- carrier_recovery
- mimo_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Equalizer Core module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
