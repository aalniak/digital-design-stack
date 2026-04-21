# RTC Block

## Overview

rtc_block maintains real-time or calendar-oriented time from a low-rate reference and exposes that time to software or supervisory logic. It sits above a raw cycle counter by adding human-meaningful time semantics.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

Wall-clock style timekeeping needs more than a free-running counter. Rollover, alarm, calibration, and sometimes calendar fields must behave consistently. rtc_block gives the stack one reusable contract for that behavior.

## Typical Use Cases

- Maintain seconds or calendar time across long operation.
- Generate alarms or wake events at scheduled times.
- Provide software with a low-power time reference separate from the main clock domain.

## Interfaces and Signal-Level Behavior

- Inputs include tick or low-rate clock, reset, optional set-time writes, and alarm configuration.
- Outputs include current time representation, alarm status, and optional periodic pulses.
- Calibration or trim inputs may adjust long-term drift.

## Parameters and Configuration Knobs

- TIME_FORMAT selects simple second count versus calendar fields.
- ALARM_EN enables compare logic.
- CALIBRATION_EN enables programmable trim.
- BACKUP_MODE defines reduced-power behavior.
- FIELD_WIDTHS size individual time fields where applicable.

## Internal Architecture and Dataflow

The block commonly uses a low-rate tick source and a hierarchy of counters or increment logic that roll over at defined boundaries. Alarm compare and trim are layered on top of that base.

## Clocking, Reset, and Timing Assumptions

The source tick must be trustworthy enough for the intended application or explicitly calibrated. Reset should define whether time returns to zero, a preset value, or a retained backup state.

## Latency, Throughput, and Resource Considerations

The relevant metrics are drift behavior, alarm timing, and update determinism rather than throughput. Hardware cost is small.

## Verification Strategy

- Check every supported rollover boundary.
- Verify alarm timing and clear policy.
- Exercise calibration or trim over long simulated intervals.
- Confirm software time writes do not create impossible intermediate values.

## Integration Notes and Dependencies

rtc_block commonly works with wakeup logic, retention, and external time discipline such as PPS. It should clearly define whether it is an authoritative wall clock or only a local real-time counter.

## Edge Cases, Failure Modes, and Design Risks

- Calendar logic invites boundary bugs if its scope is not kept narrow and explicit.
- Non-atomic time writes can produce impossible timestamps.
- Oscillator drift can make a logically correct RTC operationally weak without calibration.

## Related Modules In This Domain

- timestamp_counter
- pps_capture
- wakeup_controller
- retention_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the RTC Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
