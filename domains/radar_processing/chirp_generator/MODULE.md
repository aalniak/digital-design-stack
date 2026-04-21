# Chirp Generator

## Overview

The chirp generator creates the numerically defined sweep or waveform-control pattern used to drive FMCW or similar radar transmissions. It is a transmit-side timing and waveform primitive.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Range performance in chirped radar depends on exact sweep timing, phase continuity, and chirp-to-chirp framing. A reusable chirp source must make those choices explicit rather than scattering them through control software and NCO logic. This module provides that deterministic chirp definition.

## Typical Use Cases

- Driving numerically controlled transmit chirps in FMCW radar systems.
- Generating calibration or test sweeps for radar bring-up.
- Providing reusable chirp control in coherent radar experiments.

## Interfaces and Signal-Level Behavior

- Control side configures sweep slope, start frequency, chirp length, idle gaps, and frame structure.
- Output side emits frequency-control words, phase-control words, or waveform trigger markers for the transmit chain.
- Status side reports chirp index, frame position, and optional phase-continuity or wrap indicators.

## Parameters and Configuration Knobs

- Frequency-word width, chirp length, slope precision, and frame repetition structure.
- Idle or guard interval support, phase-continuity mode, and runtime profile selection.
- Output control format for downstream NCO or RF synthesizer interfaces.

## Internal Architecture and Dataflow

The generator increments a phase or frequency-control trajectory across each chirp according to the configured sweep law and emits timing markers that define chirp and frame boundaries. It may also support several profiles or burst structures. The contract should define whether chirps are phase continuous across frames and how reconfiguration takes effect relative to chirp boundaries.

## Clocking, Reset, and Timing Assumptions

The downstream RF or NCO chain must interpret control words in the documented units and cadence. Reset should place the chirp sequence at a known frame origin and phase policy state.

## Latency, Throughput, and Resource Considerations

The arithmetic is modest, but timing determinism is critical because any sweep irregularity propagates directly into range processing. Resource use is small and mostly counter plus increment logic.

## Verification Strategy

- Compare emitted sweep control words against a waveform reference over several chirp profiles.
- Check chirp and frame markers, phase-continuity mode, and runtime profile switching.
- Verify reset returns the generator to the documented sequence origin.

## Integration Notes and Dependencies

This block often anchors the radar frame timeline and should be documented with the transmit chain and dechirp assumptions. Integrators should also note whether waveform generation is fully digital or only control-facing here.

## Edge Cases, Failure Modes, and Design Risks

- A sweep-slope unit mismatch can distort all downstream range estimates while the waveform still looks periodic.
- Profile updates without chirp-boundary synchronization can create malformed sweeps.
- If phase-continuity assumptions differ from receiver processing expectations, calibration may fail.

## Related Modules In This Domain

- dechirp_mixer
- range_fft
- pulse_compression

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Chirp Generator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
