# Free-Running Counter

## Overview

free_running_counter is a monotonically advancing local timebase. It provides a simple notion of elapsed cycles for timestamping, timeout measurement, and scheduling.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Many blocks need elapsed time but should not each invent their own counter width, wrap rule, or capture interface. free_running_counter standardizes that local time source.

## Typical Use Cases

- Timestamp local events and transactions.
- Drive timeout and age calculations.
- Provide a coarse scheduling tick for service logic.

## Interfaces and Signal-Level Behavior

- Inputs generally include clk, reset, and optional enable or load.
- Outputs include live count and optionally a rollover pulse or captured copy.
- Some variants add compare hooks or snapshot support.

## Parameters and Configuration Knobs

- COUNT_WIDTH defines wrap interval.
- RESET_VALUE sets startup state.
- ENABLE_EN adds local gating.
- ROLLOVER_PULSE_EN adds a wrap indicator.
- CAPTURE_EN adds a latch input for coherent reads.

## Internal Architecture and Dataflow

The core is a feedback adder into a register. Practical variants add enable, capture, or compare features without changing the fundamental behavior.

## Clocking, Reset, and Timing Assumptions

The counter is local to one clock domain. If its value is exported elsewhere, the captured value should cross domains rather than the raw live bus.

## Latency, Throughput, and Resource Considerations

The main timing cost is the carry chain, especially at large widths. Feature logic such as compare or capture should avoid lengthening the base count path unnecessarily.

## Verification Strategy

- Check increment, enable, and wrap behavior.
- Verify load or clear priority if supported.
- Check rollover pulse timing exactly.
- Confirm capture returns the intended cycle value.

## Integration Notes and Dependencies

free_running_counter is commonly upstream of timer, timestamp, and monitoring blocks. Centralizing the local timebase reduces inconsistent cycle-count assumptions.

## Edge Cases, Failure Modes, and Design Risks

- Exporting the raw live bus across domains invites CDC problems.
- Control priority around enable and load must be explicit.
- Software may misread wrap intervals if width is not surfaced clearly.

## Related Modules In This Domain

- event_counter
- timer_block
- timestamp_counter
- pps_capture

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Free-Running Counter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
