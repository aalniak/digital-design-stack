# Reflectivity Estimator

## Overview

Reflectivity Estimator derives an intensity or reflectivity-related metric from return amplitude, histogram energy, or pulse-shape information. It gives downstream consumers a stable side channel that complements geometry with surface-return strength.

## Domain Context

Reflectivity estimation turns raw return strength into a more interpretable description of how strongly a surface reflected the emitted light. In 3D sensing systems this signal is useful for perception, mapping, and calibration, but only if it is separated from purely geometric effects like distance falloff and variable integration policy.

## Problem Solved

Raw return amplitude is influenced by many factors including range, exposure, gain mode, and multi-return selection. Without a dedicated estimator, downstream software tends to misuse whatever strength field happens to be available, leading to inconsistent perception features and poor cross-mode comparability.

## Typical Use Cases

- Producing an intensity channel for point clouds or depth images.
- Supporting material or surface classification alongside range.
- Flagging low-albedo surfaces that may require different perception thresholds.
- Providing amplitude information to walk-error correction and calibration diagnostics.

## Interfaces and Signal-Level Behavior

- Inputs include peak amplitude, integrated histogram energy, range, and optional receiver gain or mode metadata.
- Outputs typically provide intensity or reflectivity estimate, validity flags, and possibly saturation or clipping indicators.
- Controls define normalization policy, range compensation mode, and output scaling.
- Diagnostic outputs may expose raw and compensated strength values for tuning and calibration.

## Parameters and Configuration Knobs

- Choice of source metric such as peak height, area under curve, or first-return amplitude.
- Normalization coefficients for range, gain mode, or exposure time.
- Output bit width, clipping policy, and optional logarithmic compression.
- Support for per-channel correction tables or global intensity mapping.

## Internal Architecture and Dataflow

The estimator usually selects a strength feature, applies optional normalization and compensation, and formats the result for geometry packaging. The document should be explicit about whether the output is a raw sensor intensity, a partially normalized signal, or a physically motivated reflectivity proxy, because those are not interchangeable.

## Clocking, Reset, and Timing Assumptions

Accurate reflectivity estimation assumes the input strength metric corresponds to the chosen return and that gain or exposure metadata is available when compensation is enabled. Reset clears any adaptive normalization state and should not silently reuse stale mode information.

## Latency, Throughput, and Resource Considerations

Resource cost is low to moderate depending on normalization complexity. Latency is small and usually acceptable inline with point generation. The harder performance problem is semantic consistency across operating modes rather than arithmetic speed.

## Verification Strategy

- Check monotonicity of the output intensity versus controlled input amplitude over the supported range.
- Verify normalization across range or gain modes using synthetic calibration scenarios.
- Stress clipping and saturation paths under very strong returns.
- Compare output against a host-side reference model for each configured normalization mode.

## Integration Notes and Dependencies

Reflectivity Estimator commonly feeds Point Cloud Packer and Walk Error Corrector. It should align with perception consumers on what the intensity field represents and with calibration tooling on how any normalization was derived.

## Edge Cases, Failure Modes, and Design Risks

- Treating raw amplitude as calibrated reflectivity can mislead downstream perception or mapping.
- Normalization that depends on wrong range or gain metadata can inject artificial contrast.
- If multireturn scenes do not keep intensity aligned to the chosen surface, attributes can be attached to the wrong point.

## Related Modules In This Domain

- walk_error_corrector
- point_cloud_packer
- peak_detector
- range_calibration_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Reflectivity Estimator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
