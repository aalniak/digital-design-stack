# Timestamp Synchronizer

## Overview

Timestamp Synchronizer captures and reconciles event timing across machine subsystems so commands, feedback, and status updates share a coherent epoch. It provides the common time reference needed for deterministic coordination and debugging.

## Domain Context

Timestamp synchronization in automation systems aligns motion events, fieldbus data, sensor timestamps, and machine states to a common time base. In coordinated robotics and industrial control this timing contract is essential for replay, diagnostics, and distributed motion.

## Problem Solved

Distributed automation systems often have several clocks: drive update clocks, PLC cycles, network time domains, and local sensor timers. Without an explicit synchronizer, event ordering becomes ambiguous and high-quality diagnostics or coordination suffer.

## Typical Use Cases

- Timestamping axis events relative to a plant-wide synchronized clock.
- Aligning fieldbus cyclic data with local motion updates.
- Supporting deterministic replay and root-cause analysis of machine faults.
- Coordinating multi-axis moves that depend on common event time.

## Interfaces and Signal-Level Behavior

- Inputs include local event strobes, local counters, and optional external or fieldbus-derived time references.
- Outputs provide event timestamps, synchronized counters, and lock or discontinuity indicators.
- Control registers configure time-source selection, epoch offset, and rollover behavior.
- Diagnostic outputs may expose sync quality, missed events, and detected time jumps.

## Parameters and Configuration Knobs

- Timestamp width and sub-cycle precision.
- Number of event classes timestamped concurrently.
- Supported time-source discipline mode and offset range.
- Rollover policy and timestamp-format configuration.

## Internal Architecture and Dataflow

The module usually combines a master time counter, event latch points, CDC-safe capture, and optional discipline to an external time source. The contract should define whether timestamps correspond to local sampling instant, received network cycle boundary, or another clearly named epoch.

## Clocking, Reset, and Timing Assumptions

Inputs crossing domains must be synchronized or handshake-protected before timestamping. Reset should define whether time restarts locally or waits for a plant time source. If external sync is optional, the degraded local-only timing semantics should be stated clearly.

## Latency, Throughput, and Resource Considerations

Resource use is low, but correctness and determinism are critical. Event capture must not miss narrow strobes, and any time-domain slewing or discontinuity must be reported explicitly. The value comes from trustworthy semantics, not heavy computation.

## Verification Strategy

- Check timestamps across local and externally disciplined modes.
- Stress rollover, time jumps, and closely spaced events from several subsystems.
- Verify lock and discontinuity reporting when the external reference is lost or restored.
- Confirm event ordering remains consistent through CDC boundaries.

## Integration Notes and Dependencies

Timestamp Synchronizer interacts with servo status, machine sequencing, fieldbus endpoints, and diagnostics. It should align with plant-wide time synchronization strategies such as distributed clocks or network time models so recorded events can be compared meaningfully across devices.

## Edge Cases, Failure Modes, and Design Risks

- Two subsystems using subtly different epochs can make fault analysis misleading.
- If time jumps are hidden, coordinated motion logs become impossible to trust.
- Overstating sync quality can lead higher-level control to assume coordination that does not actually exist.

## Related Modules In This Domain

- machine_state_sequencer
- servo_loop_helper
- ethercat_slave_block
- profinet_endpoint

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Timestamp Synchronizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
