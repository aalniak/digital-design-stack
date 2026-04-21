# Startup Sequencer

## Overview

Startup Sequencer coordinates reset release, readiness checks, and ordered enable of FPGA subsystems during power-up or reconfiguration. It provides deterministic bring-up control across clocking, I/O, memory, and transceiver-dependent blocks.

## Domain Context

FPGA startup sequencing coordinates clocks, resets, calibration readiness, and sometimes configuration-done handoff into a deterministic bring-up order. In this domain it is the orchestration block that prevents subsystems from racing ahead of board and primitive readiness.

## Problem Solved

FPGA systems often depend on several conditions becoming valid in the right order: clocks locking, IODELAY calibrating, transceivers resetting, DDR PHY training, and configuration interfaces completing. A dedicated sequencer makes that dependency graph explicit.

## Typical Use Cases

- Releasing resets only after clocks and calibration resources are stable.
- Coordinating subsystem bring-up after power-up or partial reconfiguration.
- Providing a central ready status for software or test logic.
- Supporting board-specific power and reset dependencies in reusable FPGA designs.

## Interfaces and Signal-Level Behavior

- Inputs include configuration-done indicators, lock signals, calibration-ready signals, and external board-ready or power-good inputs.
- Outputs provide ordered reset releases, enable strobes, and global startup-done status.
- Control interfaces configure stage timing, optional retries, and subsystem masks.
- Status signals may expose current_stage, timeout_fault, and blocked_dependency information.

## Parameters and Configuration Knobs

- Number of stages and per-stage timeout range.
- Subsystem reset and enable fanout count.
- Optional retry or holdoff behavior.
- Warm-reset versus cold-start sequencing support.

## Internal Architecture and Dataflow

The sequencer usually contains a state machine, timers, dependency checks, and reset-enable fanout. The key contract is the exact order and conditions for stage advancement, because all attached subsystems assume their prerequisites were truly met before reset release.

## Clocking, Reset, and Timing Assumptions

The block assumes its readiness inputs are trustworthy and synchronized to the chosen startup clock. Reset should define whether the sequencer restarts from the first stage or from a warm-reset subset. If some dependencies are optional by build, those modes should be explicit rather than inferred from tied-off inputs.

## Latency, Throughput, and Resource Considerations

Startup sequencing is not throughput oriented, but timeout and dependency handling critically affect usability and diagnosability. The main tradeoff is between a simple linear sequence and a richer policy with retries or conditional branches.

## Verification Strategy

- Verify nominal bring-up order and stage timing.
- Stress missing-dependency, timeout, and lock-loss scenarios.
- Check warm-reset versus cold-start paths if both are supported.
- Run hardware bring-up tests to confirm reset release matches real primitive behavior and not only simulation assumptions.

## Integration Notes and Dependencies

Startup Sequencer coordinates MMCM/PLL Wrapper, IODELAY Controller, DDR PHY Wrapper, and Transceiver Reset FSM. It should also align with board-level power sequencing and any software-visible reset status registers.

## Edge Cases, Failure Modes, and Design Risks

- A startup sequence that works in simulation may fail on hardware if primitive-ready semantics are idealized.
- Underdocumented timeout policy can make field failures difficult to debug.
- Reconfiguration-aware designs are especially vulnerable if startup and warm-reset paths are conflated.

## Related Modules In This Domain

- mmcm_pll_wrapper
- iodelay_controller
- ddr_phy_wrapper
- transceiver_reset_fsm

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Startup Sequencer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
