# Overcurrent Shutdown

## Overview

Overcurrent Shutdown monitors current-fault indications and forces the power stage into a safe state when current exceeds allowed limits. It is the hard protection layer that overrides normal modulation immediately.

## Domain Context

Overcurrent shutdown is the protective fast path that keeps a drive or converter from destroying itself during fault conditions. In motor control and digital power systems it must act faster and more decisively than the main control loop.

## Problem Solved

Control loops and software cannot respond quickly enough to every fault. A dedicated shutdown block is needed so short-circuit, shoot-through, stall, or catastrophic load events force a deterministic gate-disable action before damage spreads.

## Typical Use Cases

- Instantly disabling inverter gates on comparator-based overcurrent trips.
- Latching faults until an operator or supervisory controller clears them.
- Coordinating staged responses such as blanking, retry, or permanent shutdown.
- Protecting motor drives, PFC stages, and digital power converters from destructive events.

## Interfaces and Signal-Level Behavior

- Inputs include comparator trips, current-threshold flags, fault clear commands, and optional blanking or arm controls.
- Outputs provide shutdown_assert, gate_disable, and latched fault status to PWM and gate-driver logic.
- Control registers configure trip polarity, latch mode, blanking windows, and restart policy.
- Status signals may include trip_source, fault_latched, retry_count, and safe-state confirmed indications.

## Parameters and Configuration Knobs

- Number of monitored fault inputs and priority rules.
- Trip latency path and blanking interval configuration.
- Latch versus auto-retry behavior.
- Output-safe-state mapping for different power-stage topologies.

## Internal Architecture and Dataflow

The block generally contains asynchronous or near-asynchronous trip capture, blanking qualification, latching, and a safe-state override path. The contract must state which faults bypass blanking and how quickly outputs are forced safe, because those are the essence of the protection guarantee.

## Clocking, Reset, and Timing Assumptions

Overcurrent inputs may come from fast analog comparators and can be asynchronous to the PWM clock. Reset behavior should default to the safe disabled state. If the design allows blanking around switching edges, the blanking window must be conservative enough not to mask real faults.

## Latency, Throughput, and Resource Considerations

Protection latency is the dominant metric. Logic cost is low, but routing and priority structure should be optimized for fast assertion. Throughput is irrelevant compared with deterministic fault response and clean latching behavior.

## Verification Strategy

- Measure trip-to-shutdown latency for each supported fault path.
- Stress blanking windows to ensure real faults are never hidden unintentionally.
- Verify latch, clear, and retry behavior after repeated trips.
- Check interaction with PWM and dead-time logic so gate outputs reach a truly safe state.

## Integration Notes and Dependencies

Overcurrent Shutdown overrides PWM, Dead Time Inserter, and sometimes Soft Start Controller behavior. It should also feed fault reporting and maintenance software so repeated trips can be diagnosed rather than merely cleared.

## Edge Cases, Failure Modes, and Design Risks

- Blanking windows that are too broad can let destructive faults persist.
- A safe-state mapping bug can leave one switch active during a supposed shutdown.
- Slow or ambiguous latch-clear behavior may cause dangerous repeated restart attempts.

## Related Modules In This Domain

- dead_time_inserter
- soft_start_controller
- center_aligned_pwm
- pfc_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Overcurrent Shutdown module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
