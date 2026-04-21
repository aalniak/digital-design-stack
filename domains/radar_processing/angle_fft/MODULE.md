# Angle FFT

## Overview

The angle FFT transforms array-channel data across antenna elements into beam or angle space, revealing directional energy in phased-array radar systems. It is a coherent spatial-processing stage built on array ordering and calibration assumptions.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Range and Doppler processing alone do not reveal target direction in array radars. An angle-space transform is needed, but only if antenna ordering, calibration, and bin indexing are shared exactly. This module provides that spatial transform boundary.

## Typical Use Cases

- Computing azimuth or elevation spectra from radar array data.
- Supporting angle estimation after range-Doppler processing.
- Providing reusable beam-space conversion in array radar systems.

## Interfaces and Signal-Level Behavior

- Input side accepts coherent complex samples ordered by antenna element, often per selected range-Doppler cell.
- Output side emits angle-bin spectra or beam-domain samples plus bin-valid metadata.
- Control side configures FFT size, array ordering, calibration enable, and output ordering mode.

## Parameters and Configuration Knobs

- Antenna count, FFT size, sample precision, and output ordering.
- Windowing across the array, zero-padding or virtual-channel support, and runtime calibration-bank selection.
- Optional selection of azimuth versus elevation processing mode.

## Internal Architecture and Dataflow

The block windows and transforms the array-channel vector across antennas, producing spatial-frequency bins that correspond to angle hypotheses under the configured array geometry. It may be used directly for beam-space energy or as an intermediate stage for angle estimation. The contract should define antenna order, FFT bin orientation, and whether outputs are in natural or shifted spatial order.

## Clocking, Reset, and Timing Assumptions

Array geometry, phase calibration, and channel alignment must be correct for angle bins to be meaningful. Reset should clear any staged vector or calibration state before processing a new coherent set.

## Latency, Throughput, and Resource Considerations

This is typically a modest FFT-sized transform compared with range processing, but it is sensitive to calibration quality. Resource use depends on antenna count and whether several dimensions are processed in parallel.

## Verification Strategy

- Compare angle-bin outputs against a reference spatial FFT for known synthetic targets and calibrated arrays.
- Check antenna ordering, bin indexing, and optional windowing behavior.
- Verify calibration-bank switching and reset behavior at coherent-frame boundaries.

## Integration Notes and Dependencies

This block usually follows range-Doppler selection or beamforming and precedes DOA estimation or detection. Integrators should document the array coordinate convention and whether zero angle lies at broadside or another reference.

## Edge Cases, Failure Modes, and Design Risks

- Antenna-order mistakes can mirror or rotate the angle spectrum while leaving magnitude patterns plausible.
- Missing channel calibration can smear targets across angle bins and be mistaken for poor SNR.
- If output bin orientation is not explicit, downstream angle logic may report inverted bearings.

## Related Modules In This Domain

- digital_beamformer
- doa_estimator
- array_calibration

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Angle FFT module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
