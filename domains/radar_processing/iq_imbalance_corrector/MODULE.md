# IQ Imbalance Corrector

## Overview

The IQ imbalance corrector compensates amplitude and phase mismatch between in-phase and quadrature channels so complex radar baseband data better reflects the intended analytic signal. It is an RF-imperfection cleanup stage early in the chain.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Mixer and front-end imperfections create image leakage and constellation distortion in complex radar signals, which then pollute range and angle processing. This module provides the reusable compensation stage that corrects those mismatches before deeper coherent processing.

## Typical Use Cases

- Correcting analog IQ mismatch in radar receiver baseband data.
- Reducing image terms before FFT-based range and Doppler processing.
- Providing reusable front-end calibration in coherent radar designs.

## Interfaces and Signal-Level Behavior

- Input side accepts complex I and Q samples from the receive front end.
- Output side emits corrected complex samples and optional calibration telemetry.
- Control side loads imbalance coefficients, selects banks, and manages update timing.

## Parameters and Configuration Knobs

- Sample precision, correction-coefficient width, and bank count.
- Static versus adaptive correction mode, output scaling, and optional bypass.
- Runtime update synchronization and saturation policy.

## Internal Architecture and Dataflow

The block applies a small linear correction to I and Q using configured gain and cross-coupling terms so the resulting complex signal better matches an ideal quadrature representation. The documentation should define whether coefficients are direct matrix elements, gain or phase approximations, or another form, and when updates become active.

## Clocking, Reset, and Timing Assumptions

Correction coefficients are meaningful only for the documented RF mode, mixer chain, and sample ordering. Reset should select a known bank or neutral bypass state.

## Latency, Throughput, and Resource Considerations

The arithmetic is modest, typically a small matrix-like correction per sample, but it often runs at high front-end rates. Resource use depends on coefficient precision and whether adaptive estimation is included.

## Verification Strategy

- Compare corrected outputs against a reference imbalance model on synthetic image-leakage cases.
- Check coefficient-bank switching, scaling, and bypass behavior.
- Verify that reset and profile changes do not create sample-stream discontinuities.

## Integration Notes and Dependencies

This block usually sits before range processing and often before array calibration, so its corrected-signal convention should be documented with those stages. Integrators should also note whether calibration coefficients come from factory characterization or runtime estimation.

## Edge Cases, Failure Modes, and Design Risks

- If I and Q are swapped or signed differently upstream, the correction can worsen image leakage while appearing numerically stable.
- Coefficient updates mid-frame can perturb coherent processing.
- A mismatch between adaptive and static calibration assumptions can produce mode-dependent behavior that is hard to diagnose.

## Related Modules In This Domain

- array_calibration
- dechirp_mixer
- range_fft

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the IQ Imbalance Corrector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
