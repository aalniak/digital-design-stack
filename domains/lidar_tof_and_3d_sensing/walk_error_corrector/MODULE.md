# Walk Error Corrector

## Overview

Walk Error Corrector compensates range or timing bias caused by return-amplitude dependence in the detection path. It refines measured return timing using amplitude, pulse-shape, or histogram-derived information so depth remains accurate across varying reflectivity and distance.

## Domain Context

Walk error correction addresses amplitude-dependent timing bias in threshold-based ranging front ends. In LiDAR and ToF sensors, stronger returns can cross a comparator earlier than weaker returns even when the true path length is identical, so this module is essential whenever front-end physics makes measured time intensity-dependent.

## Problem Solved

If stronger returns appear earlier in the digital timing chain than weaker ones, raw range will vary with reflectivity rather than only with distance. That creates warped geometry, especially across scenes with mixed surface materials. A dedicated correction stage isolates this sensor-specific effect and applies the compensation consistently.

## Typical Use Cases

- Correcting comparator-threshold walk in discrete ToF receivers.
- Applying amplitude-based timing corrections to histogram peak estimates.
- Reducing material-dependent depth bias across mixed-reflectivity scenes.
- Switching correction curves across front-end gain modes or receiver configurations.

## Interfaces and Signal-Level Behavior

- Inputs usually include raw timing or range plus an amplitude-related metric such as peak height, integrated energy, or pulse width.
- Outputs provide corrected timing or corrected range along with validity and possible residual confidence flags.
- Control registers load walk-correction curves, select interpolation mode, and enable or disable the correction path.
- Status may expose out-of-range amplitude conditions or missing compensation profile warnings.

## Parameters and Configuration Knobs

- Correction table depth and interpolation precision.
- Supported amplitude metric format and dynamic range.
- Whether correction is applied in timing units or directly in range units.
- Per-channel versus global correction profile support.

## Internal Architecture and Dataflow

The module generally combines a quality-checked amplitude metric, a lookup or parametric correction function, and an adder or subtractor that adjusts the measured time or distance. The important contract is that the correction domain and sign are explicit, because downstream calibration must know whether walk has already been removed.

## Clocking, Reset, and Timing Assumptions

Walk correction assumes the amplitude metric is trustworthy and aligned to the same physical return as the timing measurement. Reset clears profile state or marks the correction inactive. If the front end changes gain or threshold settings dynamically, the correct compensation profile must follow that mode change atomically.

## Latency, Throughput, and Resource Considerations

Computation is light, typically a table lookup plus interpolation. Latency should be deterministic and low so this block can sit inline on the real-time ranging path. Memory use is modest unless large per-channel compensation tables are required.

## Verification Strategy

- Inject synthetic amplitude-dependent timing bias and confirm corrected outputs collapse back to the true range.
- Check behavior when amplitude is outside the calibrated correction range.
- Verify mode or gain-dependent profile switching does not mix coefficients across adjacent returns.
- Compare corrected results against calibration data used to derive the walk model.

## Integration Notes and Dependencies

Walk Error Corrector usually follows Peak Detector or Range Calibration Engine depending on where the system defines raw versus calibrated timing. It works closely with Reflectivity Estimator and calibration management because the amplitude metric used here must be physically meaningful and consistently scaled.

## Edge Cases, Failure Modes, and Design Risks

- Applying walk correction twice can produce a bias as large as the original error.
- Using an amplitude metric from the wrong return or wrong processing stage can worsen accuracy.
- Hidden mode dependence can make geometry shift when receiver gain changes under bright scenes.

## Related Modules In This Domain

- range_calibration_engine
- reflectivity_estimator
- peak_detector
- multi_return_resolver

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Walk Error Corrector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
