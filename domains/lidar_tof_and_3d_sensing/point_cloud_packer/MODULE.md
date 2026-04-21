# Point Cloud Packer

## Overview

Point Cloud Packer assembles geometric and attribute fields into structured point records or frames. It converts per-shot or per-pixel ranging results into a transport-ready representation of 3D points.

## Domain Context

Point-cloud packing is the boundary where the sensor stops thinking in terms of timing bins and begins exporting geometry. This block takes calibrated ranges, directions, and optional intensity or quality fields and formats them into a stable per-point representation for host software, storage, or real-time perception.

## Problem Solved

Even when ranges are correct, the sensor is not easy to consume until outputs are normalized into a consistent point format with clear metadata. Without a dedicated packer, different paths may emit incompatible coordinate conventions, field orderings, or validity semantics.

## Typical Use Cases

- Building XYZ plus intensity records for host-side perception.
- Packaging range image outputs from a flash or solid-state ToF sensor.
- Attaching timestamp, return index, and quality metadata to each point.
- Streaming reduced or full-fidelity point products to storage or networking layers.

## Interfaces and Signal-Level Behavior

- Inputs include calibrated range, scan angle or pixel index, reflectivity, timestamp, and validity metadata.
- Outputs are framed point records, usually containing coordinates or range-angle tuples plus attribute fields.
- Control registers choose output coordinate convention, enabled attributes, frame boundaries, and packing width.
- Status ports often expose dropped_point, frame_done, fifo_level, and format_version indicators.

## Parameters and Configuration Knobs

- Output schema, such as XYZ, spherical, or range-image style records.
- Numeric precision for coordinates, timestamps, and intensity fields.
- Maximum points per frame and support for multiple returns per shot.
- Optional compression or omission of invalid points.

## Internal Architecture and Dataflow

The packer typically performs coordinate conversion or tuple assembly, attribute alignment, validity filtering, and serialization into an output FIFO. The contract should define exactly how direction and range become geometry, including sign conventions, axis orientation, and whether coordinates are sensor-relative or already compensated for platform motion.

## Clocking, Reset, and Timing Assumptions

Inputs are assumed temporally aligned so the range, angle, and timestamp belong to the same physical return. Reset clears partial frames and sequence state. If coordinate conversion is included, the module assumes the necessary trigonometric or table-driven direction model matches the active scan pattern exactly.

## Latency, Throughput, and Resource Considerations

Resource use depends on coordinate conversion complexity and output buffering. Throughput must sustain the full point rate under worst-case multireturn scenes. Latency is usually acceptable so long as frame structure remains deterministic and backpressure is handled without silently discarding points.

## Verification Strategy

- Feed synthetic ranges and angles to verify coordinate conversion and axis conventions.
- Stress frame boundaries, invalid-point suppression, and multireturn record ordering.
- Check that timestamps and intensity fields stay aligned with the correct point under output backpressure.
- Validate packed output against a parser or host-side reference schema.

## Integration Notes and Dependencies

Point Cloud Packer consumes Range Calibration Engine, Scan Pattern Generator, Timestamp Synchronizer, and Reflectivity Estimator outputs, then feeds DMA, networking, or logging infrastructure. It must be documented in a way host and perception teams can treat as a stable sensor ABI.

## Edge Cases, Failure Modes, and Design Risks

- A hidden coordinate-convention mismatch can invalidate downstream perception even when ranges are correct.
- Misaligned attribute packing can attach intensity or timestamp to the wrong point.
- Dropping invalid points without preserving count semantics can break host assumptions about organized clouds.

## Related Modules In This Domain

- range_calibration_engine
- scan_pattern_generator
- timestamp_synchronizer
- reflectivity_estimator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Point Cloud Packer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
