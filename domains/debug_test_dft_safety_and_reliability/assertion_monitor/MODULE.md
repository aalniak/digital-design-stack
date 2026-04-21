# Assertion Monitor

## Overview

Assertion Monitor evaluates configured hardware invariants at runtime and emits fault, event, or trace outputs when those invariants are violated. It provides a reusable on-chip checker for protocol and safety properties.

## Domain Context

Assertion monitoring is the runtime observability layer that turns protocol, timing, or safety invariants into explicit on-chip checks. In this domain it extends verification intent into hardware-visible diagnostics or safety mechanisms.

## Problem Solved

Many critical invariants are known during design and verification, but without a dedicated runtime checker they disappear after synthesis or rely only on external observation. A dedicated assertion monitor keeps those assumptions visible inside the product.

## Typical Use Cases

- Checking protocol handshake rules in deployed systems.
- Monitoring safety invariants such as mutually exclusive enables or timing windows.
- Generating trace or fault events when rare corner-case violations occur in the field.
- Supporting silicon bring-up with hardware-resident protocol monitors.

## Interfaces and Signal-Level Behavior

- Inputs are monitored design signals plus clocks, resets, and optional trigger-arm controls.
- Outputs provide assertion_fail, sticky status, event pulses, and optional source identifiers.
- Control interfaces configure enable masks, sticky versus pulse mode, and lifecycle or debug visibility.
- Status signals may expose assertion_active, fail_count, and clear_ack indications.

## Parameters and Configuration Knobs

- Number of monitored assertions or channels.
- Single-cycle versus temporal window depth.
- Sticky latch, pulse-only, or counter-based reporting mode.
- Optional per-assertion severity or route-to-trace policy.

## Internal Architecture and Dataflow

The monitor generally contains simple combinational checks, temporal state machines, and reporting latches or counters. The key contract is whether a failure is purely diagnostic or also drives safety-critical actions, because the same logical predicate has very different implications in those two roles.

## Clocking, Reset, and Timing Assumptions

The block assumes monitored signals are in the intended clock domain or are synchronized appropriately before use. Reset typically clears temporal history and sticky failures according to policy. If some assertions are intended only for debug builds, the lifecycle and synthesis inclusion policy should be explicit.

## Latency, Throughput, and Resource Considerations

Area scales with the number and complexity of temporal properties. Latency is usually one cycle or a few cycles after violation. The important tradeoff is between rich temporal checking and acceptable area or false-positive risk under asynchronous or reset-heavy behavior.

## Verification Strategy

- Validate each monitored property against directed pass and fail scenarios.
- Stress reset, clock gating, and domain-crossing conditions to ensure failures are meaningful rather than artifacts.
- Check sticky, counter, and pulse reporting semantics.
- Verify routing into trace or safety responses matches configuration.

## Integration Notes and Dependencies

Assertion Monitor often feeds Event Recorder, Error Logger, Trace Funnel, and Safe State Controller. It should align with formal and simulation property definitions so runtime checks represent the same intent engineers validated pre-silicon.

## Edge Cases, Failure Modes, and Design Risks

- Poorly synchronized monitored signals can create false failures that erode trust in the monitor.
- Turning debug-only assertions into safety actions without revalidation can create unintended trips.
- Underdocumented reset behavior can make sticky-failure logs hard to interpret in the field.

## Related Modules In This Domain

- event_recorder
- error_logger
- safe_state_controller
- trace_funnel

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Assertion Monitor module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
