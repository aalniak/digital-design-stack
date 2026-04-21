# Dechirp Mixer

## Overview

The dechirp mixer combines the received radar signal with a reference chirp or local replica so beat-frequency information can be extracted for later range processing. It is a front-end coherent translation stage in FMCW-style radar chains.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Raw FMCW returns are not immediately useful for range processing; they must be mixed with the transmit reference to reveal beat frequencies proportional to delay. This module performs that critical frequency-translation step with an explicit phase and framing contract.

## Typical Use Cases

- Forming beat-frequency signals from FMCW radar returns.
- Preparing receive data for range FFT processing.
- Providing reusable dechirp functionality in coherent radar systems.

## Interfaces and Signal-Level Behavior

- Receive side accepts complex or real radar return samples.
- Reference side accepts a local chirp replica or control needed to generate one.
- Output side emits beat-frequency samples and optional phase or saturation status aligned to chirp boundaries.

## Parameters and Configuration Knobs

- Sample precision, complex versus real mode, reference precision, and output scaling.
- Chirp-boundary handling, phase convention, and optional DC-removal or leakage-cancel support.
- Runtime waveform profile selection and reset behavior.

## Internal Architecture and Dataflow

The block multiplies the receive path by the conjugate or otherwise appropriate reference chirp representation so the resulting output contains the desired beat terms for range processing. It may also include basic leakage suppression or scaling. The contract should define whether outputs are complex baseband, real IF-like signals, and how chirp boundaries align with the emitted samples.

## Clocking, Reset, and Timing Assumptions

The reference chirp must share timing and sweep law with the transmitted waveform, or the beat interpretation fails. Reset should clear any reference-phase or chirp-state context before the next frame begins.

## Latency, Throughput, and Resource Considerations

This stage is a moderate per-sample multiply and often sits early in a high-rate radar chain, so throughput and scaling are important. Resource use depends on complex arithmetic and any leakage-cancel add-ons.

## Verification Strategy

- Compare beat outputs against a dechirp reference on synthetic delayed chirps and leakage cases.
- Check chirp-boundary alignment, phase convention, and output scaling.
- Verify reset and waveform-profile changes occur only at safe chirp boundaries.

## Integration Notes and Dependencies

The dechirp mixer usually sits between ADC capture and range FFT processing, so its output convention should be documented with both neighbors. Integrators should also note whether DC or leakage cancellation is included here or in a separate stage.

## Edge Cases, Failure Modes, and Design Risks

- A conjugation or sign mistake can invert beat-frequency interpretation and corrupt range estimates.
- Reference-timing mismatch may create smeared or drifting range spectra that resemble RF problems.
- If chirp boundaries are misaligned, successive FFT windows will not correspond to clean sweeps.

## Related Modules In This Domain

- chirp_generator
- range_fft
- iq_imbalance_corrector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Dechirp Mixer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
