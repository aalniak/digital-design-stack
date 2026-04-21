# Timestamp Counter

## Overview

timestamp_counter is a wide monotonically increasing counter intended specifically for timestamping, interval measurement, and time capture. It is often the authoritative local time source for hardware events.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

A generic free-running counter does not always expose the capture, compare, and adjustment hooks that real timestamping needs. timestamp_counter packages those expectations into one reusable primitive.

## Typical Use Cases

- Timestamp packets, sensor samples, or debug events.
- Provide a common hardware timebase for software and peripherals.
- Feed PPS capture or disciplined time logic with a high-resolution counter.

## Interfaces and Signal-Level Behavior

- Inputs commonly include clk, reset, enable, capture requests, and optional adjustment controls.
- Outputs include current timestamp, captured values, and optional compare or rollover pulses.
- Some variants expose multiple capture channels or compare channels.

## Parameters and Configuration Knobs

- COUNT_WIDTH sets wrap interval.
- CAPTURE_CHANNELS sizes dedicated capture interfaces.
- COMPARE_EN enables timer-like compare behavior.
- ADJUST_EN supports stepped or slewed correction.
- ROLLOVER_EN enables wrap indication outputs.

## Internal Architecture and Dataflow

The core is a wide counter plus capture registers and optional compare logic. More capable versions also support offset or rate adjustment so the timebase can be disciplined against an external reference.

## Clocking, Reset, and Timing Assumptions

The counter belongs to one local clock domain and is authoritative only there unless a higher-level discipline scheme says otherwise. Adjustment policy must state whether time can jump or only slew.

## Latency, Throughput, and Resource Considerations

Very wide counters can create carry-chain timing pressure, especially when compare or capture logic is attached directly. Latency through capture logic should be fixed and documented.

## Verification Strategy

- Check monotonic progression and wrap behavior.
- Verify capture timing under concurrent increment and capture.
- Exercise compare behavior near wrap.
- If adjustment exists, verify monotonic or documented non-monotonic behavior exactly.

## Integration Notes and Dependencies

timestamp_counter usually feeds PPS capture, DMA timestamps, event tracing, and software-visible timing services. It should be clearly identified as authoritative local time when several counters exist.

## Edge Cases, Failure Modes, and Design Risks

- Software may assume timestamps are globally comparable when they are only local.
- Wide counters can become timing-sensitive if feature creep attaches too much logic.
- Undocumented time adjustment behavior can break ordering assumptions.

## Related Modules In This Domain

- free_running_counter
- pps_capture
- rtc_block
- frequency_meter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Timestamp Counter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
