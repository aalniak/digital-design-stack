# MIMO Detector

## Overview

The MIMO detector estimates transmitted symbol vectors from multi-antenna received observations using the channel model and chosen detection algorithm. It is a receive-path spatial-inference block for multi-stream communication systems.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Multiple-input multiple-output systems mix several transmitted streams together in the channel, so per-stream decisions require joint detection rather than simple scalar slicing. This module provides that multi-stream estimation stage with an explicit algorithmic contract.

## Typical Use Cases

- Detecting spatially multiplexed symbols in MIMO receivers.
- Providing stream estimates and soft metrics to demappers or decoders.
- Serving as reusable spatial detection infrastructure in SDR systems.

## Interfaces and Signal-Level Behavior

- Input side accepts received vector observations and channel estimates for the current symbol or subcarrier.
- Output side emits detected symbol hypotheses, soft metrics, or post-detection quality indicators.
- Control side configures detection mode, stream count, and numeric precision or iteration limits.

## Parameters and Configuration Knobs

- Antenna and stream count, symbol precision, channel-estimate width, and detector mode.
- Output soft-metric width, matrix precision, and support for QR-like preprocessing or candidate pruning.
- Runtime profile selection and stream-order convention.

## Internal Architecture and Dataflow

The detector solves for the most likely transmitted symbol vector under the channel model using the selected method, which may range from linear equalization to successive interference cancellation or more exhaustive search. The contract should state the exact stream ordering, output metric meaning, and whether outputs are hard decisions, soft decisions, or both.

## Clocking, Reset, and Timing Assumptions

Channel estimates and received vectors must share a documented ordering and normalization, and the chosen detection mode must match the modulation and stream count. Reset should clear any iterative or staged matrix state between blocks or symbols as required.

## Latency, Throughput, and Resource Considerations

MIMO detection can be computationally expensive because cost grows with stream count, constellation size, and chosen algorithm. Resource use is dominated by matrix and metric arithmetic rather than simple control logic.

## Verification Strategy

- Compare detected symbols or soft metrics against a reference detector on known MIMO channel realizations.
- Check stream ordering, channel-matrix interpretation, and detector-mode switching.
- Verify reset and per-block initialization for any iterative or decomposed modes.

## Integration Notes and Dependencies

This block sits after channel estimation and before demapping or decoding, so all three should share documented stream and symbol conventions. Integrators should also state whether the detector targets throughput, near-optimal detection quality, or a compromise between the two.

## Edge Cases, Failure Modes, and Design Risks

- A stream-order mismatch can swap user data between layers while constellation quality still looks reasonable.
- Numerical scaling errors in the channel matrix may only show up on ill-conditioned channels.
- Soft-output semantics that differ from decoder expectations can erase the value of an otherwise correct detector.

## Related Modules In This Domain

- channel_estimator
- equalizer_core
- ldpc_codec

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the MIMO Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
