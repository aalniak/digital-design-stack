# Carrier Recovery

## Overview

The carrier recovery block estimates and corrects residual carrier phase or frequency error so received constellations align with the decision regions expected by later demodulation stages. It is a central receive-path synchronization loop.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

After downconversion and coarse correction, received symbols often still rotate due to residual carrier offset or phase noise. Without carrier recovery, demappers and decoders see a distorted constellation. This module provides the fine synchronization loop needed to stabilize that constellation.

## Typical Use Cases

- Correcting residual phase rotation in PSK and QAM receivers.
- Serving as a fine synchronization stage after coarse frequency estimation.
- Providing reusable carrier tracking in SDR and baseband receivers.

## Interfaces and Signal-Level Behavior

- Input side accepts complex baseband symbols or filtered samples.
- Output side emits corrected symbols plus optional phase-estimate or lock telemetry.
- Control side configures loop bandwidth, detector mode, and enable or reset policy.

## Parameters and Configuration Knobs

- Symbol precision, phase accumulator width, loop-filter coefficients, and detector type.
- Decision-directed versus pilot-aided mode, lock thresholds, and update cadence.
- Runtime coefficient profiles and optional holdover or freeze support.

## Internal Architecture and Dataflow

The block compares received symbols against expected constellation orientation or pilot references, derives a phase error, filters that error, and rotates the incoming symbols by the negative estimated offset. It may also integrate some frequency correction. The contract should define whether correction is applied per symbol, per sample, or with a separate phase rotator stage.

## Clocking, Reset, and Timing Assumptions

The loop assumes the modulation and training context match the selected detector and that coarse frequency error is already within capture range. Reset should initialize phase state and lock status to a known acquisition-friendly condition.

## Latency, Throughput, and Resource Considerations

Carrier recovery is moderate in cost and runs at sample or symbol rate with a relatively small amount of state, but its dynamic behavior is critical to overall receiver quality. Resource use is shaped by rotator precision and loop arithmetic.

## Verification Strategy

- Compare corrected constellation and phase estimate against a reference loop over several residual offsets and phase-noise scenarios.
- Check acquisition, steady-state lock, and reset behavior.
- Verify decision-directed and pilot-aided modes if both are supported.

## Integration Notes and Dependencies

This block typically follows coarse CFO estimation and precedes equalization or demapping depending on the architecture, so its assumed capture range and output convention should be documented with those neighbors. Integrators should also note whether lock telemetry is used for higher-layer gating.

## Edge Cases, Failure Modes, and Design Risks

- If the residual offset exceeds the loop capture range, the block may look noisy rather than obviously broken.
- A symbol-rotation sign convention mismatch can mirror or rotate constellations systematically.
- Loop coefficients that are stable in one SNR regime may fail badly in another if not documented.

## Related Modules In This Domain

- cfo_estimator
- equalizer_core
- qam_mapper_demapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Carrier Recovery module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
