# MMCM/PLL Wrapper

## Overview

MMCM/PLL Wrapper encapsulates FPGA clock-management primitives and exposes a normalized interface for generated clocks, lock status, and reconfiguration or reset control. It provides a reusable clock-generation abstraction over vendor-specific resources.

## Domain Context

Clock-generation wrappers around MMCMs and PLLs are the platform-specific bridge between abstract clocking intent and vendor primitive instantiation. In this domain they package primitive control, lock behavior, and reset sequencing into a reusable clocking contract for the rest of the design.

## Problem Solved

Vendor clock primitives differ in port sets, reset timing, and dynamic reconfiguration semantics. A dedicated wrapper keeps those differences localized so the rest of the design sees a consistent clocking interface.

## Typical Use Cases

- Generating derived clocks from a board or transceiver reference.
- Providing lock-aware clock outputs to subsystems with clean reset sequencing.
- Abstracting vendor-specific primitive details behind a portable local interface.
- Supporting dynamic clock-frequency or phase configuration in FPGA platforms.

## Interfaces and Signal-Level Behavior

- Inputs include reference clock, primitive reset, optional reconfiguration controls, and enable or power-down signals.
- Outputs provide generated clock(s), lock status, and optional phase or frequency-status metadata.
- Control interfaces configure startup sequencing and, if supported, dynamic reconfiguration requests.
- Status signals may expose lock_lost, reset_done, and reconfiguration_busy indications.

## Parameters and Configuration Knobs

- Number of output clocks and each output ratio or phase setting.
- Static versus dynamically reconfigurable operating mode.
- Primitive family selection if several vendor generations are supported.
- Lock-filter or startup-hold timing parameters.

## Internal Architecture and Dataflow

The wrapper usually instantiates the vendor primitive, adds reset and lock conditioning, and exposes a simplified control or status surface to the rest of the design. The key contract is when output clocks are considered usable relative to lock and reset, because downstream domains rely on that sequencing for safe startup.

## Clocking, Reset, and Timing Assumptions

The wrapper assumes the reference clock meets the primitive input constraints and jitter requirements. Reset behavior should clearly define whether output clocks are suppressed or simply marked invalid during acquisition. If dynamic reconfiguration is supported, the acceptable quiesce state of downstream logic during reconfig should be explicit.

## Latency, Throughput, and Resource Considerations

Area cost is low because most functionality resides in the hard primitive. The important performance characteristics are lock time, jitter transfer, and stability rather than logic speed. The main tradeoff is between exposing rich primitive control and keeping downstream integration simple.

## Verification Strategy

- Verify lock, reset, and output-enable sequencing against the targeted primitive behavior.
- Check startup timing and lock-loss response under simulated reference changes where possible.
- Validate parameter sets for each supported clock plan.
- Run end-to-end reset and clock-bring-up tests on hardware or vendor-accurate simulation models.

## Integration Notes and Dependencies

MMCM/PLL Wrapper feeds Startup Sequencer, Transceiver Reset FSM, and ordinary logic clock domains. It should align with board clock sources and with any constraints or timing exceptions required by the FPGA toolchain.

## Edge Cases, Failure Modes, and Design Risks

- Treating primitive lock as instantly safe without wrapper-level conditioning can destabilize startup.
- Overabstracting away vendor-specific limitations may encourage unsupported configurations.
- Dynamic reconfiguration without clear downstream quiesce policy can corrupt running subsystems.

## Related Modules In This Domain

- startup_sequencer
- iodelay_controller
- transceiver_reset_fsm
- serdes_calibration_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the MMCM/PLL Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
