# Trace Funnel

## Overview

Trace Funnel arbitrates and merges multiple trace or debug event streams into a shared downstream trace path while preserving enough source identity and ordering metadata for later analysis. It provides consolidation for on-chip trace infrastructure.

## Domain Context

A trace funnel aggregates several debug or trace sources into a smaller number of output channels or buffers. In this domain it exists to preserve observability from several subsystems without dedicating a separate high-bandwidth output for each one.

## Problem Solved

Modern SoCs and subsystems produce more trace sources than external pins or trace memories can accommodate directly. A dedicated funnel makes arbitration, tagging, and overflow semantics explicit so trace consumers know what was preserved or dropped.

## Typical Use Cases

- Combining CPU, accelerator, bus, and event trace streams into one sink.
- Feeding a shared trace buffer or off-chip debug interface.
- Reducing dedicated trace-routing overhead inside a complex design.
- Providing time-ordered observability across several subsystems during bring-up.

## Interfaces and Signal-Level Behavior

- Inputs are several trace streams or event channels with valid and optional timestamp or source metadata.
- Outputs provide one merged trace stream plus overflow, arbitration, and source-tag information.
- Control interfaces configure priority, round-robin, or filtering policy and source enable masks.
- Status signals may expose source_stall, drop_count, and funnel_overflow indicators.

## Parameters and Configuration Knobs

- Number of input trace sources.
- Merged output width and source-tag width.
- Arbitration policy and buffering depth.
- Optional timestamp pass-through or insertion support.

## Internal Architecture and Dataflow

The funnel generally contains arbitration, source tagging, buffering, and backpressure management for several independent trace sources. The key contract is what ordering guarantees survive arbitration and what happens when the sink cannot keep up, because trace utility depends heavily on understanding loss and reordering behavior.

## Clocking, Reset, and Timing Assumptions

The module assumes each input trace source obeys the documented valid or ready protocol and, if timestamps are provided, that they share a meaningful time base or are clearly source-local. Reset clears buffers and drop counters according to policy. If some trace sources are security sensitive, funnel policy should respect lifecycle or debug gating.

## Latency, Throughput, and Resource Considerations

Trace funnels are bandwidth-management blocks, so throughput and buffering dominate. The tradeoff is between preserving more sources at once and the increased complexity or loss risk of shared output bandwidth. Deterministic drop accounting is often as important as raw merge rate.

## Verification Strategy

- Stress arbitration under several simultaneous active trace sources.
- Verify source tagging and ordering behavior under backpressure.
- Check overflow and drop-count reporting when output bandwidth is insufficient.
- Run end-to-end decode tests to ensure merged trace remains parseable by downstream tools.

## Integration Notes and Dependencies

Trace Funnel commonly aggregates Event Recorder, Bus Monitor, Assertion Monitor, and CPU or accelerator trace. It should align with external tooling and timestamp conventions so merged traces remain analytically useful.

## Edge Cases, Failure Modes, and Design Risks

- Without clear ordering and drop semantics, a merged trace can mislead debugging rather than help it.
- One noisy source can starve more important traces if arbitration policy is poorly chosen.
- Security-sensitive sources may accidentally become observable through the same funnel used for routine bring-up.

## Related Modules In This Domain

- event_recorder
- bus_monitor
- assertion_monitor
- jtag_tap

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Trace Funnel module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
