# Pulse Synchronizer

## Overview

pulse_synchronizer transfers a sparse one-bit event from one clock domain to another and regenerates a clean local pulse. It is the standard event CDC primitive for the library.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

A pulse that is only one cycle wide in its source domain can be missed entirely in an unrelated destination domain. pulse_synchronizer solves that by transferring state rather than the raw narrow pulse.

## Typical Use Cases

- Cross a completion pulse into a CPU or monitor clock.
- Launch a wake or interrupt event across domains.
- Notify a destination domain about a rare fault or threshold event.

## Interfaces and Signal-Level Behavior

- Source side usually has src pulse and optional busy.
- Destination side produces dst pulse and sometimes valid or busy status.
- Handshake-style variants may return an acknowledge to prevent overlap.

## Parameters and Configuration Knobs

- SYNC_STAGES sets synchronizer depth.
- MODE selects toggle, handshake, or stretched-pulse style.
- BUSY_EN exposes source-side overlap protection.
- PULSE_WIDTH_MODE defines destination pulse width.
- RESET_POLICY defines in-flight reset handling.

## Internal Architecture and Dataflow

Most implementations convert the source pulse into a persistent toggle or request, synchronize that across, and edge-detect it in the destination domain. The design question is usually whether overlapping pulses must be blocked or queued.

## Clocking, Reset, and Timing Assumptions

Source and destination clocks are asynchronous. The source must obey any busy rule if the module supports only one event in flight. Reset must return internal state to a consistent idle value in both domains.

## Latency, Throughput, and Resource Considerations

Latency is mostly synchronizer depth. Throughput is limited by the time needed for one event to cross safely, so this block is for sparse events rather than bursty traffic.

## Verification Strategy

- Sweep many clock ratios and phases.
- Verify one legal source pulse produces exactly one destination pulse.
- Check overlap handling with and without busy protection.
- Exercise reset during an in-flight event.

## Integration Notes and Dependencies

pulse_synchronizer should feed control and status logic, not payload paths. If event rate becomes high, async FIFO or a counter-based scheme is usually more appropriate.

## Edge Cases, Failure Modes, and Design Risks

- Using it for back-to-back high-rate events can lose pulses.
- Reset asymmetry can leave internal toggle state inconsistent if not designed carefully.
- Teams sometimes misuse it as a general status synchronizer rather than an event synchronizer.

## Related Modules In This Domain

- bus_synchronizer
- async_fifo
- reset_synchronizer
- interrupt_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pulse Synchronizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
