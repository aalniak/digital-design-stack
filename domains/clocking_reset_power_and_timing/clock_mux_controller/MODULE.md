# Clock Mux Controller

## Overview

clock_mux_controller owns the policy around selecting among several clock sources. It decides when a switch is allowed and how clock-source status is interpreted, distinct from the low-level glitchless switch fabric.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

A raw source-select bit is not enough in systems with backup clocks or power modes. The design needs one place that knows whether a source is healthy, whether switching is allowed, and what to report while a switch is in progress.

## Typical Use Cases

- Choose between primary and backup references.
- Switch a subsystem between low-power and performance clocks.
- Coordinate source changes during startup or fault recovery.

## Interfaces and Signal-Level Behavior

- Inputs include requested source, source-health signals, and optional inhibit or force controls.
- Outputs drive a switch or mux primitive and report current source or pending state.
- The controller may also interact with reset or gating policy around a transition.

## Parameters and Configuration Knobs

- NUM_SOURCES sets supported choices.
- DEFAULT_SOURCE defines startup selection.
- WAIT_FOR_STABLE_EN requires a healthy indication before committing.
- SWITCH_POLICY chooses software-driven or automatic failover.
- STATUS_STICKY_EN preserves switch or fault history.

## Internal Architecture and Dataflow

The controller is usually a small FSM that watches health signals, commands a switch, waits for settle conditions, and then releases downstream logic. Keeping this policy separate from the physical switch makes portability and verification much easier.

## Clocking, Reset, and Timing Assumptions

Candidate sources have meaningful health or lock indications. Reset establishes a known source choice. If switching requires gating or reset, the policy should be explicit rather than hidden in surrounding logic.

## Latency, Throughput, and Resource Considerations

The important metric is bounded and understandable switch latency, not throughput. Logic cost is low, but policy mistakes can create system-wide downtime.

## Verification Strategy

- Exercise requested switches under healthy and unhealthy source conditions.
- Verify automatic failover if supported.
- Check interaction with reset or gating around transitions.
- Inject contradictory health signals to confirm deterministic policy.

## Integration Notes and Dependencies

clock_mux_controller typically drives glitchless_clock_switch and consumes pll_lock_monitor or clock_fail_detector status. It should own policy, not pulse integrity.

## Edge Cases, Failure Modes, and Design Risks

- Failover without hysteresis can oscillate between sources.
- Confusing policy and physical switching leaves dangerous ownership gaps.
- Switching clocks without reset coordination can corrupt downstream state even if the edges are clean.

## Related Modules In This Domain

- glitchless_clock_switch
- clock_fail_detector
- pll_lock_monitor
- clock_gating_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Clock Mux Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
