# Radar Array Calibration

## Overview

The radar array calibration block stores or applies per-channel phase and amplitude corrections so array processing assumes a coherent and balanced front end. It is a support stage that underpins beamforming and angle estimation quality.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Antenna arrays and RF chains are never perfectly matched, and small phase or gain errors can severely degrade angle processing. This module provides the reusable correction layer that compensates those mismatches before spatial transforms.

## Typical Use Cases

- Correcting per-channel phase and gain mismatch before angle processing.
- Applying calibration derived from factory or field measurements in radar arrays.
- Providing reusable array-equalization infrastructure across spatial-processing chains.

## Interfaces and Signal-Level Behavior

- Input side accepts complex channel samples arranged by antenna element.
- Output side emits corrected channel samples with preserved coherent timing.
- Control side loads calibration coefficients, selects banks, and configures update boundaries.

## Parameters and Configuration Knobs

- Channel count, coefficient precision, complex-gain format, and bank count.
- Runtime bank switching, per-channel enable masks, and output scaling or clamp behavior.
- Optional temperature or mode-indexed coefficient selection.

## Internal Architecture and Dataflow

The block multiplies each channel by a complex or scalar correction factor that compensates front-end mismatch. It may support several calibration banks for different modes or temperatures. The contract should define when coefficient updates become active and whether channels switch coherently as one set.

## Clocking, Reset, and Timing Assumptions

Calibration coefficients are meaningful only for the documented array geometry, RF mode, and channel ordering. Reset should select a known bank or bypass state rather than leaving channel gains ambiguous.

## Latency, Throughput, and Resource Considerations

The arithmetic is moderate and usually one complex multiply per channel sample, with throughput tied to array sample rate. Resource use scales with channel count and coefficient precision.

## Verification Strategy

- Compare corrected channel vectors against a calibration reference using known synthetic mismatch cases.
- Check channel ordering, bank switching, and coefficient scaling.
- Verify that all channels update coherently at the documented frame or chirp boundary.

## Integration Notes and Dependencies

This block generally sits early in the coherent radar chain before beamforming or spatial FFTs, and its coefficient provenance should be documented with those consumers. Integrators should also note whether calibration is mandatory or optional in degraded modes.

## Edge Cases, Failure Modes, and Design Risks

- A channel-order mismatch in calibration can worsen array response while still looking numerically valid.
- Mid-frame coefficient changes can corrupt coherence across channels.
- If calibration banks are not tied clearly to RF modes, deployment behavior may vary with configuration in hard-to-debug ways.

## Related Modules In This Domain

- angle_fft
- digital_beamformer
- iq_imbalance_corrector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Radar Array Calibration module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
