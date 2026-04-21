# Timestamp Synchronizer

## Overview

Timestamp Synchronizer distributes or reconciles time references across the LiDAR or ToF pipeline and emits consistent event timestamps for shots, returns, and frames. It is the timing glue that makes the sensor outputs globally interpretable.

## Domain Context

Timestamp synchronization is the cross-cutting timing contract for a 3D sensor. It aligns shot events, capture windows, scan positions, and system time so geometry products can be fused with platform motion, cameras, or other sensors without ambiguity.

## Problem Solved

A ranging pipeline often spans several timing domains: shot launch, TDC capture, scan control, and host interface clocks. Without an explicit synchronizer, modules may assign different epochs to the same physical event, creating subtle but damaging spatial and fusion errors.

## Typical Use Cases

- Timestamping each laser shot in a common sensor time base.
- Aligning range outputs with scan-angle state and external PPS or system clocks.
- Supporting sensor fusion where LiDAR points must be matched to inertial or camera data.
- Detecting clock slips or timing discontinuities during long autonomous missions.

## Interfaces and Signal-Level Behavior

- Inputs include local event strobes such as shot_start, frame_start, encoder_latch, or TDC hit ready, plus one or more time references.
- Outputs provide latched timestamps, synchronized time counters, and validity or discontinuity flags.
- Control registers define epoch source, offset adjustment, and rollover behavior.
- Status outputs often include sync_locked, epoch_step_detected, and counter_overflow indicators.

## Parameters and Configuration Knobs

- Timestamp width and sub-tick resolution.
- Supported number of timestamped event classes.
- Offset and drift-compensation precision if external synchronization is supported.
- Rollover period and timestamp-format selection.

## Internal Architecture and Dataflow

The module usually combines a master time counter, event latching, CDC-safe time transfer, and optional synchronization to an external reference such as PPS or a platform clock. The key architectural guarantee is that all latched event times are comparable because they derive from one coherent epoch model.

## Clocking, Reset, and Timing Assumptions

Event inputs that cross domains must be synchronized or handshake-protected before timestamping. Reset behavior should define whether time restarts from zero, waits for an external epoch, or continues from retained state. If time is disciplined externally, the design must specify how jumps or slews are represented.

## Latency, Throughput, and Resource Considerations

Resource cost is low, but correctness requirements are high. Event latching must occur without losing narrow strobes, and timestamp distribution must not become a CDC bottleneck. Deterministic timestamp semantics are usually more important than nanoseconds of extra latency.

## Verification Strategy

- Check event timestamp capture across all supported event classes and clock-domain crossings.
- Verify rollover, epoch reset, and external-discipline behavior.
- Stress closely spaced events to ensure no latching ambiguity or missed pulses occurs.
- Confirm timestamp alignment between shot, scan, and output frames using known synthetic schedules.

## Integration Notes and Dependencies

Timestamp Synchronizer touches Laser Trigger Controller, Scan Pattern Generator, TDC Capture, and Point Cloud Packer. It should also align with system-level fusion infrastructure so timestamps have a clear meaning outside the sensor itself.

## Edge Cases, Failure Modes, and Design Risks

- If two modules timestamp the same shot against different epochs, geometry fusion errors may appear far downstream.
- Poor CDC handling can create rare timestamp corruption that is hard to reproduce.
- Undocumented rollover or epoch-step behavior can break long-duration logging and replay tools.

## Related Modules In This Domain

- laser_trigger_controller
- scan_pattern_generator
- tdc_capture
- point_cloud_packer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Timestamp Synchronizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
