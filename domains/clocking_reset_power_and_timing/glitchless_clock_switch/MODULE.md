# Glitchless Clock Switch

## Overview

glitchless_clock_switch performs the low-level transfer of a destination clock from one source to another without creating runt or overlapping pulses. It is the physical switching primitive behind clock-source failover and mode changes.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

Naively muxing unrelated clocks with ordinary combinational logic creates dangerous pulse artifacts. glitchless_clock_switch solves the edge-integrity problem of the switch itself.

## Typical Use Cases

- Switch between primary and backup references.
- Move a domain between low-power and high-speed clocks.
- Support fault recovery where the destination clock must stay clean.

## Interfaces and Signal-Level Behavior

- Inputs are candidate source clocks plus a switch request or source select.
- Output is one switched clock and optional source-status feedback.
- Some variants also expose busy or accepted-switch status.

## Parameters and Configuration Knobs

- NUM_SOURCES sets the number of candidate clocks.
- TECHNIQUE selects switching style or target primitive.
- MIN_IDLE_EN inserts a documented idle gap if required.
- STATUS_EN enables source feedback.
- TECH_CELL selects a target-specific implementation path.

## Internal Architecture and Dataflow

Safe switching often uses source gating and sequencing rules that ensure only one source can drive the output at a time. On some targets the only correct implementation is a hardened primitive, and the RTL wrapper must make that expectation visible.

## Clocking, Reset, and Timing Assumptions

The module is responsible for pulse integrity, not high-level policy. A controller should already have decided the requested source is legal. Reset defines which source, if any, drives the output at startup.

## Latency, Throughput, and Resource Considerations

Switch latency depends on source phase relationship and any inserted dead time. Logic cost is tiny, but implementation sensitivity is extremely high because the wrong primitive choice invalidates the design.

## Verification Strategy

- Use timing-aware or gate-level models where possible.
- Exercise switching between unrelated clock phases.
- Check startup source selection and stopped-source behavior.
- Verify source-status outputs against actual switch ownership.

## Integration Notes and Dependencies

glitchless_clock_switch should be driven by clock_mux_controller and monitored by clock health logic. It should not hide source-health policy internally.

## Edge Cases, Failure Modes, and Design Risks

- RTL that looks correct may still be unsafe if it does not map to the right primitive.
- Stopped source clocks can expose deadlock cases.
- Assuming switching is instantaneous can break downstream sequencing.

## Related Modules In This Domain

- clock_mux_controller
- clock_fail_detector
- pll_lock_monitor
- clock_gating_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Glitchless Clock Switch module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
