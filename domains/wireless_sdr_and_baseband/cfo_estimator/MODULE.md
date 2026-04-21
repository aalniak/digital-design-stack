# CFO Estimator

## Overview

The CFO estimator measures carrier frequency offset between the received signal and the local reference so later stages can compensate that error. It is usually an acquisition or coarse-correction stage on the receive path.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Receivers rarely start with perfect carrier alignment, and large frequency error will overwhelm fine loops if not estimated early. This module provides the coarse or initial frequency-offset estimate needed to stabilize later baseband processing.

## Typical Use Cases

- Estimating coarse carrier offset during receiver acquisition.
- Providing initial correction values to carrier recovery loops.
- Supporting reusable synchronization chains in SDR receivers.

## Interfaces and Signal-Level Behavior

- Input side accepts preamble, pilot, or repeated-symbol structures suitable for offset estimation.
- Output side emits a frequency-offset estimate and optional confidence or validity status.
- Control side configures observation length, estimation mode, and handoff timing.

## Parameters and Configuration Knobs

- Sample precision, estimator observation length, offset range, and output word width.
- Training-sequence assumptions, pilot structure mode, and confidence metric representation.
- Runtime profile selection and reset or rearm policy.

## Internal Architecture and Dataflow

The estimator derives frequency error from phase progression across repeated structures, pilot symbols, or another documented training pattern and packages the result into a correction word for downstream mixers or loops. The contract should state whether the estimate is in normalized radian increment, Hz-like units, or some receiver-specific tuning word.

## Clocking, Reset, and Timing Assumptions

The block assumes the selected training structure is present and interpreted in the documented order. Reset should clear internal accumulators and confidence state before a new acquisition attempt.

## Latency, Throughput, and Resource Considerations

CFO estimation is moderate in cost and usually runs only during acquisition windows or pilot-bearing intervals. Resource use depends on observation length and phase-accumulation precision rather than continuous data rate.

## Verification Strategy

- Compare estimated offsets against a reference estimator across several true CFO values and SNR conditions.
- Check training-structure assumptions, output scaling, and confidence validity.
- Verify reset and reacquisition behavior when the estimator is run intermittently.

## Integration Notes and Dependencies

This block often feeds a digital mixer or carrier recovery loop, so its output scaling and sign convention should be documented with those consumers. Integrators should also state whether estimates are one-shot, averaged, or continuously refreshed.

## Edge Cases, Failure Modes, and Design Risks

- A sign mismatch between estimator and correction stage can double the apparent offset instead of removing it.
- Estimator outputs can look numerically reasonable yet still be in the wrong units for the downstream NCO.
- If the assumed training pattern changes across waveform profiles, the estimator may fail silently.

## Related Modules In This Domain

- carrier_recovery
- correlator_bank
- digital_mixer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the CFO Estimator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
