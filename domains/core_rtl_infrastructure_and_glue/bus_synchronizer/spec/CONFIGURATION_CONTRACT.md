# Bus Synchronizer Configuration Contract

## Module Family

- Family name: `bus_synchronizer`
- Domain: Core RTL Infrastructure and Glue
- Current implementation name: `bus_synchronizer`

## Purpose

`bus_synchronizer` transfers a coherent multi-bit word between asynchronous clock domains at low rate. The current implementation chooses the safest reusable profile first: a single-entry request or acknowledge handshake with source-side backpressure and destination-side valid signaling.

## Current Public Contract

The current implementation exposes:

- `src_clk`
- `src_rst_n`
- `src_data`
- `src_valid`
- `src_ready`
- `dst_clk`
- `dst_rst_n`
- `dst_data`
- `dst_valid`
- `dst_pulse`
- `dst_ready`

Semantics:

- `src_valid && src_ready` launches one coherent word into the crossing path.
- The source-side holding register retains that word until the destination consumes it.
- `dst_valid` indicates a destination-resident coherent word waiting for acceptance.
- `dst_pulse` indicates that a newly captured word arrived in the destination domain.
- `dst_valid && dst_ready` completes the transfer and frees the source side for the next word.

## Parameters

| Parameter | Type | Legal range | Default | Meaning |
| --- | --- | --- | --- | --- |
| `DATA_WIDTH` | integer | `>= 1` | `32` | Width of the transferred bus |
| `SYNC_STAGES` | integer | `>= 2` | `2` | Synchronizer depth for request and acknowledge control paths |
| `RESET_VALUE` | vector | any `DATA_WIDTH` value | zero | Destination-visible value after reset |

## Shared Semantic Contract

- Only one transfer may be in flight at a time in the current implementation.
- Each accepted source word produces exactly one destination arrival.
- The source data is held stable internally for the full crossing and acknowledgment window.
- `dst_valid` holds its word stable until `dst_ready` completes the transfer.
- Reset returns both sides to idle with no outstanding transfer.

## Current Implementation Choice

The current implementation is the handshake-based profile recommended by the module documentation:

- source-side hold register
- synchronized request toggle into destination
- destination capture register with `dst_valid`
- synchronized acknowledge toggle back to source

This gives a coherent and misuse-resistant baseline for low-rate control or status crossings.

## Future Improvement Directions

- additional wrapper profiles for snapshot-only or toggle-only update indication
- optional sticky destination-valid behavior versus pulse-only notification
- stronger formal coverage of one-to-one transfer and no-spurious-update properties
- optional simulation assertions for illegal source changes while a transfer is pending
