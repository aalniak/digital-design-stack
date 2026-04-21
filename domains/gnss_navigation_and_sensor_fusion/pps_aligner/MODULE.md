# PPS Aligner

## Overview

PPS Aligner generates or aligns PPS events to the receiver time solution and reports the timing relationship between internal counters and the one-second boundary. It supports timing applications that need a disciplined hardware pulse rather than only numerical timestamps.

## Domain Context

PPS alignment is the hardware bridge between internal receiver time and an externally visible timing pulse. In timing-capable GNSS systems it makes the navigation solution useful beyond positioning by aligning one-pulse-per-second outputs to the receiver clock and decoded GNSS time base.

## Problem Solved

Producing a PPS pulse with the right absolute epoch and low jitter requires more than toggling a GPIO every second. It must account for receiver clock bias, decoded GNSS time, and output latency. A dedicated aligner isolates those responsibilities.

## Typical Use Cases

- Driving a disciplined PPS output for downstream equipment synchronization.
- Measuring offset between local receiver time and an external timing reference.
- Supporting time-transfer applications in embedded GNSS designs.
- Providing one-second epoch markers to logging or sensor-fusion subsystems.

## Interfaces and Signal-Level Behavior

- Inputs include receiver time counters, GNSS second-boundary information, and optional external reference pulses.
- Outputs provide PPS pulse, epoch-valid indication, and offset or health metadata.
- Control registers configure output polarity, pulse width, offset trim, and holdover behavior.
- Status signals may report sync_locked, epoch_error, and missing-reference conditions.

## Parameters and Configuration Knobs

- Timestamp precision and output pulse width.
- Allowed offset trim range and resolution.
- Support for internally generated versus externally aligned PPS.
- Holdover timeout and quality thresholds.

## Internal Architecture and Dataflow

The aligner typically combines epoch detection, offset compensation, pulse generation, and monitoring of pulse-to-time consistency. The crucial contract is whether the pulse marks the top of the solved second, a predicted future second, or a delayed version corrected for known hardware latency.

## Clocking, Reset, and Timing Assumptions

This block assumes the decoded GNSS time solution is trustworthy enough to define second boundaries. Reset should suppress PPS until timing validity is re-established. If operating in holdover, the drift model or discipline source should be documented.

## Latency, Throughput, and Resource Considerations

Resource use is small, but timing integrity is paramount. Jitter and deterministic latency matter more than arithmetic depth. The block must never emit ambiguous or duplicated pulses during epoch transitions.

## Verification Strategy

- Check PPS timing against synthetic second-boundary inputs and known offsets.
- Stress holdover entry and exit behavior when timing validity is lost and restored.
- Verify pulse width, polarity, and trim application across parameter settings.
- Confirm offset metadata matches the actual difference between internal time and emitted pulse.

## Integration Notes and Dependencies

PPS Aligner interacts with Disciplined Clock Controller, Pseudorange Engine, and system-level timing outputs. It should share a clear epoch model with any host software or external equipment that interprets the pulse.

## Edge Cases, Failure Modes, and Design Risks

- A PPS pulse with wrong epoch labeling is worse than no pulse because it can silently mis-synchronize a system.
- If holdover behavior is not surfaced clearly, consumers may overtrust degraded timing.
- Duplicated or skipped pulses during relock can destabilize downstream clocks.

## Related Modules In This Domain

- disciplined_clock_controller
- pseudorange_engine
- kalman_fusion_engine
- strapdown_integrator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PPS Aligner module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
