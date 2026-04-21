# Event Recorder

## Overview

Event Recorder captures configured event pulses or state transitions into a timestamped or sequenced log suitable for later inspection. It provides compact historical visibility into system behavior and fault ordering.

## Domain Context

An event recorder is the lightweight chronology layer for important on-chip state changes and faults. In this domain it bridges the gap between immediate fault pulses and richer trace systems by collecting discrete time-ordered events with bounded metadata.

## Problem Solved

Many failures are intermittent and occur long before a host can interrogate status registers. A dedicated recorder preserves a short but meaningful history so engineers can reconstruct what happened around an incident.

## Typical Use Cases

- Capturing assertion failures, protocol faults, or safety events in time order.
- Providing postmortem context after a system reset or safe-state transition.
- Logging rare debug triggers without enabling full continuous trace.
- Recording lifecycle or power-related events for support analysis.

## Interfaces and Signal-Level Behavior

- Inputs are event pulses, optional source IDs, timestamps or sequence counters, and control signals for arm or clear.
- Outputs provide recorded event entries, event_count, and buffer-full or overflow status.
- Control interfaces configure source enable masks, recording depth, and whether timestamps are local or externally supplied.
- Status signals may expose recorder_full, drop_count, and armed state.

## Parameters and Configuration Knobs

- Number of event sources and source-ID width.
- Buffer depth and record width.
- Timestamp inclusion and timestamp width.
- Circular-buffer versus stop-on-full policy.

## Internal Architecture and Dataflow

The recorder generally contains event qualification, optional timestamp tagging, FIFO or ring-buffer storage, and readout logic. The key contract is whether old events are overwritten when full or recording halts, because postmortem value depends heavily on that policy.

## Clocking, Reset, and Timing Assumptions

The module assumes events are synchronized or safely captured relative to the recording clock. Reset may clear the buffer or preserve it through soft resets depending on policy, and that choice should be documented clearly. If timestamps come from an external source, their meaning and continuity assumptions should be explicit.

## Latency, Throughput, and Resource Considerations

Resource cost is moderate and dominated by buffer storage. Event rates are usually low, but bursty fault scenarios can overflow a shallow recorder quickly. The main tradeoff is between richer records and keeping enough depth to preserve useful chronology.

## Verification Strategy

- Inject events with known order and verify recorded sequence and timestamps.
- Stress back-to-back bursts that exceed nominal event rate.
- Check circular-buffer versus stop-on-full behavior.
- Verify reset preservation or clearing semantics under the intended reset classes.

## Integration Notes and Dependencies

Event Recorder often consumes Assertion Monitor, Bus Monitor, Brownout, and Fault Injector outputs and feeds Trace Funnel or software-readable logs. It should align with Error Logger so summary and chronology views tell a coherent story.

## Edge Cases, Failure Modes, and Design Risks

- If overflow behavior is unclear, users may assume a complete history when they only have the tail or head of it.
- Timestamp discontinuities can make event ordering misleading after resets or clock changes.
- Logging too many low-value sources can crowd out the events that actually matter.

## Related Modules In This Domain

- trace_funnel
- error_logger
- assertion_monitor
- brownout_fault_interface

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Event Recorder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
