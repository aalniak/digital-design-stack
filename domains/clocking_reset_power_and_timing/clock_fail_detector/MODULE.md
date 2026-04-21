# Clock Fail Detector

## Overview

clock_fail_detector supervises a monitored clock and reports when it stops, drifts outside an allowed activity window, or otherwise becomes unhealthy relative to a trusted reference.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

If a critical clock fails silently, the rest of the system can misbehave in confusing ways. clock_fail_detector gives the design an explicit health signal for timing infrastructure.

## Typical Use Cases

- Detect loss of an external reference clock.
- Monitor a derived clock for minimum and maximum activity.
- Trigger safe-state, reset, or failover action when a clock becomes unhealthy.

## Interfaces and Signal-Level Behavior

- Inputs usually include a monitored clock, reference clock, reset, and programmable windows or thresholds.
- Outputs include healthy or fault indication plus optional sticky status.
- Some variants also raise an interrupt or failover request.

## Parameters and Configuration Knobs

- TIMEOUT_WINDOW sets maximum gap between monitored edges.
- MIN_COUNT and MAX_COUNT bound acceptable activity in a window.
- STICKY_FAULT_EN latches faults until cleared.
- FILTER_DEPTH rejects transient disturbances.
- AUTO_RECOVER_EN defines whether healthy status can return automatically.

## Internal Architecture and Dataflow

The detector usually counts monitored-clock edges inside a reference window or counts reference cycles between monitored edges. Filtering is often added so one irregular edge does not trip the whole system.

## Clocking, Reset, and Timing Assumptions

At least one trusted reference timebase must remain alive. Reset should define whether the detector starts optimistic or pessimistic. If the monitored domain stops entirely, the fault logic must still live elsewhere.

## Latency, Throughput, and Resource Considerations

The meaningful metric is detection latency versus nuisance-trip resistance rather than throughput. Tighter windows detect faster but are more sensitive to jitter.

## Verification Strategy

- Stop the monitored clock and measure fault latency.
- Sweep monitored frequency around the acceptance window.
- Inject jitter and missing edges.
- Check sticky-fault and recovery behavior.

## Integration Notes and Dependencies

clock_fail_detector commonly feeds clock_mux_controller, reset logic, and safety handlers. A fault bit without a documented response path is only half a solution.

## Edge Cases, Failure Modes, and Design Risks

- An untrusted reference makes the health judgment meaningless.
- Aggressive thresholds create false trips.
- Automatic recovery can oscillate if hysteresis is not thought through.

## Related Modules In This Domain

- pll_lock_monitor
- glitchless_clock_switch
- reset_sequencer
- clock_mux_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Clock Fail Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
