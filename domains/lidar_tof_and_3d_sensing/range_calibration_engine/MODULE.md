# Range Calibration Engine

## Overview

Range Calibration Engine converts raw peak or return timing into calibrated range estimates using stored offset, scale, and compensation models. It is the point where sensor-specific timing behavior becomes corrected physical distance.

## Domain Context

Range calibration compensates the nonidealities that sit between measured time and true distance: fixed timing offsets, temperature drift, per-channel delay skew, optical path differences, and nonlinearities in the TDC or histogram interpretation chain. In LiDAR and ToF systems, this engine is what makes raw timing useful as metric geometry.

## Problem Solved

Even when timing capture is precise, it is not automatically accurate. Uncalibrated launch delays, receiver offsets, per-pixel path differences, and temperature dependence can create significant ranging error. A dedicated calibration engine is needed to apply those corrections consistently and transparently.

## Typical Use Cases

- Applying factory-measured range offsets across channels or pixels.
- Compensating temperature- or mode-dependent timing drift.
- Correcting nonlinear bin-to-distance mapping in direct ToF imagers.
- Switching calibration profiles across laser power modes, lenses, or hardware revisions.

## Interfaces and Signal-Level Behavior

- Inputs are raw peak or return locations plus frame, channel, and optional environmental metadata.
- Outputs provide calibrated range values, validity flags, and often a quality or residual indicator.
- Control interfaces load calibration tables, select active profiles, and read back version or checksum metadata.
- Optional service ports support calibration updates from embedded software or manufacturing flows.

## Parameters and Configuration Knobs

- Supported correction terms such as fixed offset, scale factor, LUT-based nonlinearity, and temperature compensation.
- Precision of input timing and output range representation.
- Number of channels or pixels addressed by distinct calibration data.
- Profile count and double-buffering support for safe calibration updates.

## Internal Architecture and Dataflow

The engine usually contains profile storage, metadata selection, arithmetic or LUT-based correction stages, and integrity checks. In more advanced sensors it may also consume temperature or operating-mode inputs and choose different coefficients dynamically, but the core contract is still simple: the same raw timing under the same profile must always yield the same calibrated range.

## Clocking, Reset, and Timing Assumptions

This block assumes the meaning of raw peak location is stable and documented, including whether it represents a max bin, centroid, or interpolated estimate. Reset should fall back to a known valid profile or explicitly invalidate outputs until calibration data is loaded.

## Latency, Throughput, and Resource Considerations

Calibration arithmetic is generally inexpensive compared with histogramming or TDC capture. Latency is low and deterministic, which is important because range is often consumed immediately by downstream point-cloud packers. Memory cost rises if large per-pixel LUTs are supported.

## Verification Strategy

- Apply synthetic calibration tables and confirm output range matches the expected corrected value exactly.
- Check profile switching, checksum failure, and missing-data behavior.
- Verify temperature or mode input selection chooses the intended coefficient set.
- Compare calibrated outputs against a host-side golden model over the supported timing range.

## Integration Notes and Dependencies

Range Calibration Engine sits between return extraction and geometry packaging, feeding Point Cloud Packer and any downstream filters. It should integrate with manufacturing tooling and calibration databases so on-device coefficients remain traceable to external characterization records.

## Edge Cases, Failure Modes, and Design Risks

- A wrong profile or stale coefficient set can bias every point in the cloud without obvious runtime faults.
- If the block hides whether outputs are calibrated or raw, downstream consumers may apply correction twice or not at all.
- Mixed-profile updates can create inconsistent geometry across adjacent scan lines.

## Related Modules In This Domain

- peak_detector
- multi_return_resolver
- walk_error_corrector
- point_cloud_packer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Range Calibration Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
