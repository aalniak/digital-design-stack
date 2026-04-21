# Laser Trigger Controller

## Overview

Laser Trigger Controller generates the precisely timed control events that launch laser shots and synchronize the rest of the ranging chain around each shot. It converts host-programmed scan cadence and pulse policy into deterministic trigger behavior for the optical transmitter and related acquisition hardware.

## Domain Context

The laser trigger controller is the timing authority for an active optical ranging frontend. In LiDAR and ToF systems it coordinates when a laser pulse is emitted, how long the emission window lasts, and how that emission lines up with receiver blanking, TDC arming, and scan-position timing.

## Problem Solved

A ranging stack only works if transmit timing is controlled tightly enough that measured return delays can be referenced back to a known launch instant. If pulse launch, receiver gating, and scan timing are distributed across unrelated logic, range bias, missed shots, and eye-safety or thermal issues become much more likely.

## Typical Use Cases

- Issuing single-shot triggers for direct ToF measurements.
- Coordinating burst firing patterns in scanning LiDAR systems.
- Aligning transmitter emission with SPAD or APD receiver blanking windows.
- Enforcing maximum duty cycle and shot spacing to satisfy thermal and eye-safety constraints.

## Interfaces and Signal-Level Behavior

- Control inputs typically include arm, enable, shot period, pulse width, burst count, and scan-synchronization settings.
- Outputs may drive laser_enable, trigger_pulse, blanking_window, and shot_sync events for downstream timestamp logic.
- Status signals often include busy, shot_done, fault_inhibit, and shot_counter indications.
- Optional interlocks accept thermal, current-limit, or enclosure-safety inhibits that can veto emission.

## Parameters and Configuration Knobs

- Trigger pulse width and timing resolution relative to the system clock.
- Maximum burst length, minimum inter-shot spacing, and programmable dead time.
- Support for externally synchronized versus internally scheduled firing.
- Optional double-buffering of shot descriptors or scan-position-linked firing tables.

## Internal Architecture and Dataflow

A common implementation combines a shot scheduler, fine-grain pulse generator, safety interlock gate, and sync-event distributor. In scanning systems it may also sample position counters or encoder states before allowing a shot, ensuring the optical pulse is associated with the intended beam direction.

## Clocking, Reset, and Timing Assumptions

The module assumes a stable timing reference and clean synchronization to any external scan trigger domain. Reset must force the laser inactive immediately and clear any partially queued shot sequence. If external interlocks arrive asynchronously, they must be synchronized in a fail-safe way that errs toward suppressing emission.

## Latency, Throughput, and Resource Considerations

Logic cost is modest, but timing integrity is critical. Jitter and cycle-to-cycle determinism matter more than raw throughput. The controller must schedule shots without skipping cadence under worst-case scan rates while still enforcing mandatory dead time and safety vetoes.

## Verification Strategy

- Check trigger width, launch period, and burst sequencing over full parameter range.
- Verify safety interlocks suppress emission immediately and predictably.
- Confirm shot_sync markers align to the exact launch event consumed by downstream timestamp logic.
- Stress external sync handoff and descriptor updates to ensure no duplicate or truncated shots occur.

## Integration Notes and Dependencies

Laser Trigger Controller sits upstream of the optical transmitter and interacts closely with TDC Capture, receiver blanking control, and Scan Pattern Generator. It should also integrate with platform safety supervision so invalid thermal or enclosure states halt firing before energy leaves the system.

## Edge Cases, Failure Modes, and Design Risks

- A one-cycle ambiguity in launch timing can become a systematic range bias across the entire point cloud.
- Ignoring interlocks or dead time can damage the laser or violate safety requirements.
- If scan position and shot timing drift apart, points may be assigned the wrong direction.

## Related Modules In This Domain

- tdc_capture
- scan_pattern_generator
- tof_histogrammer
- timestamp_synchronizer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Laser Trigger Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
