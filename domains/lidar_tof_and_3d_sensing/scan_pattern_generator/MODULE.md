# Scan Pattern Generator

## Overview

Scan Pattern Generator produces the scan-position schedule or steering state used to assign direction to emitted laser shots. It provides the directional timeline that turns scalar range measurements into spatial geometry.

## Domain Context

The scan pattern generator defines where the sensor looks over time. In scanning LiDAR systems it is the module that maps time or encoder state into beam direction so each laser shot can be associated with a known azimuth, elevation, mirror phase, or raster position.

## Problem Solved

A range sample without trustworthy pointing information is not a point in space. If scan phase, mirror control, or position indexing are handled inconsistently across the design, point-cloud geometry becomes warped or misregistered even when the timing chain itself is correct.

## Typical Use Cases

- Driving raster, rosette, or spinning scan schedules in a LiDAR sensor.
- Associating each emitted shot with encoder-derived azimuth and elevation state.
- Generating simulation or calibration scan patterns for factory characterization.
- Supporting programmable dwell or skip patterns in region-of-interest scanning modes.

## Interfaces and Signal-Level Behavior

- Inputs may include external encoder counts, frame-start triggers, or mode-select commands from a host processor.
- Outputs typically provide scan indices, angle codes, position-valid markers, and sync pulses for shot timing.
- Control registers configure scan pattern type, step size, dwell counts, and frame length.
- Status ports often indicate frame_active, position_lock, end_of_scan, and pattern_error conditions.

## Parameters and Configuration Knobs

- Angular resolution or position-code width.
- Maximum scan length, repeat period, and supported pattern families.
- Support for table-driven versus procedurally generated scan paths.
- Whether scan state is open-loop generated or closed-loop corrected from encoder feedback.

## Internal Architecture and Dataflow

Implementations range from simple counters to table-driven trajectory engines with encoder fusion. The critical contract is deterministic association between a shot and a position sample, including whether position is latched before, during, or after the laser trigger event.

## Clocking, Reset, and Timing Assumptions

The scan generator assumes its angle reference and any external encoders share a known relation to the shot timing domain. Reset should restart the scan in a documented phase state or hold invalid until a new frame-start alignment arrives.

## Latency, Throughput, and Resource Considerations

Arithmetic cost is modest, but temporal alignment matters greatly. Throughput must match the maximum shot rate and scan update rate without skipped indices. Buffered table-driven patterns may cost memory, especially when supporting nonrepeating scan trajectories.

## Verification Strategy

- Check scan index and angle progression for each supported pattern mode.
- Verify position values align to the intended trigger instant when paired with laser shots.
- Stress encoder discontinuities, frame restarts, and mode switches.
- Confirm table-driven patterns loop or terminate exactly as documented.

## Integration Notes and Dependencies

Scan Pattern Generator works closely with Laser Trigger Controller, Timestamp Synchronizer, and Point Cloud Packer. It should also integrate with external encoder calibration so geometry consumers can interpret output directions in a stable mechanical reference frame.

## Edge Cases, Failure Modes, and Design Risks

- A small off-by-one error in scan indexing can distort the entire spatial map.
- If position is sampled at the wrong time relative to the shot, moving mirrors or spinning heads will misplace points.
- Undocumented frame restart behavior can create discontinuities that look like mapping errors downstream.

## Related Modules In This Domain

- laser_trigger_controller
- timestamp_synchronizer
- point_cloud_packer
- range_calibration_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Scan Pattern Generator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
