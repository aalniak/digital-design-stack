# Pulse Synchronizer Configuration Contract

## Module Family

- Family name: `pulse_synchronizer`
- Domain: Core RTL Infrastructure and Glue
- Current implementation name: `pulse_synchronizer`

## Purpose

`pulse_synchronizer` moves a sparse one-bit event from a source clock domain into a destination clock domain and regenerates a clean destination-domain pulse. The current implementation favors a safe one-event-in-flight toggle-based protocol over a looser raw-pulse stretching approach.

## Current Public Contract

The current implementation exposes:

- `src_clk`
- `src_rst_n`
- `src_pulse`
- `src_busy`
- `dst_clk`
- `dst_rst_n`
- `dst_pulse`

Semantics:

- `src_pulse` is a one-cycle source-domain event request.
- `src_busy` indicates that an earlier event is still in flight and a new pulse must not be launched if guaranteed delivery is required.
- `dst_pulse` is a regenerated one-cycle pulse in the destination domain.

## Parameters

| Parameter | Type | Legal range | Default | Meaning |
| --- | --- | --- | --- | --- |
| `SYNC_STAGES` | integer | `>= 2` | `2` | Synchronizer depth for request and acknowledge CDC chains |

## Shared Semantic Contract

- Each accepted source pulse produces exactly one destination pulse.
- Pulses launched while `src_busy` is asserted are not guaranteed to be transferred.
- Reset returns the synchronizer to an idle state with no event in flight.
- The module supports sparse events, not queued or bursty traffic.

## Current Implementation Choice

The implemented profile is toggle-based with source-side busy protection:

- source pulse toggles a request state when the path is idle
- destination detects the synchronized toggle and emits a one-cycle pulse
- destination acknowledges the event by returning the observed toggle

This is the safe default profile for the module family.

## Future Improvement Directions

- optional wrapper or parameter for exposing a destination valid or sticky-event output
- optional overlap-detection diagnostics
- clearer family split if a handshake variant with explicit acknowledgment ports is added later
- deeper formal proof of one-to-one event transfer under public-contract assumptions
