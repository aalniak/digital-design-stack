# PPS Capture

## Overview

pps_capture timestamps a pulse-per-second event relative to a local timebase and produces a clean measurement or synchronization event. It is the basic bridge between coarse absolute timing references and local counters.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

A one-pulse-per-second reference is simple conceptually, but capturing it reliably inside a fast digital system requires edge conditioning, timestamping, and sometimes CDC protection. pps_capture packages that behavior.

## Typical Use Cases

- Align a local timestamp counter to an external reference.
- Measure local drift over one-second intervals.
- Provide software with precise second-boundary captures.

## Interfaces and Signal-Level Behavior

- Inputs usually include local clock, local timestamp bus, PPS input, and reset.
- Outputs include captured timestamp, capture-valid pulse, and optional interval or fault metrics.
- Some variants also expose missed-pulse or double-pulse indicators.

## Parameters and Configuration Knobs

- TIMESTAMP_WIDTH sets captured value width.
- EDGE_MODE selects edge polarity.
- FILTER_EN adds deglitching or qualification.
- INTERVAL_MEASURE_EN computes delta between captures.
- CDC_MODE defines how an asynchronous PPS input is handled.

## Internal Architecture and Dataflow

The module generally includes an input conditioner, edge detector, and capture register that latches a local timebase. More elaborate variants also compute deltas or compare observed intervals against expectation.

## Clocking, Reset, and Timing Assumptions

A meaningful local timebase must exist. If PPS is asynchronous, the module should document capture uncertainty and the effect of synchronization latency. Reset should define whether the first capture is immediately considered valid.

## Latency, Throughput, and Resource Considerations

The relevant metric is timestamp determinism rather than throughput. Resource usage is light and mostly comes from capture storage and optional interval logic.

## Verification Strategy

- Capture ideal one-second pulses and verify delta behavior.
- Inject jitter, missing pulses, and double pulses.
- Exercise asynchronous arrivals near local clock edges.
- Check first-valid behavior after reset.

## Integration Notes and Dependencies

pps_capture commonly pairs with timestamp counters, software timekeeping, and clock-discipline logic. It should clearly document whether it reports the sampled edge or a compensated estimate.

## Edge Cases, Failure Modes, and Design Risks

- Asynchronous PPS input can create off-by-one timestamp ambiguity.
- Software may over-trust single-sample captures without accounting for capture uncertainty.
- Lost-pulse handling matters because stale captures can look superficially valid.

## Related Modules In This Domain

- timestamp_counter
- free_running_counter
- frequency_meter
- rtc_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PPS Capture module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
