# Checksum Offload Engine

## Overview

The checksum offload engine computes or verifies protocol checksums on streaming packets so endpoint CPUs and control software do not need to touch every byte. It is most useful for IPv4, UDP, TCP, and other protocols that rely on one's-complement accumulation over header and payload fields.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Software checksum work creates avoidable memory bandwidth pressure and latency, while bespoke RTL implementations often mishandle byte alignment, pseudo-header inclusion, or odd-length payloads. This module gives packet paths a consistent checksum service with explicit metadata describing where accumulation begins, how final folding occurs, and whether insertion or verification is required.

## Typical Use Cases

- Inserting IPv4 header checksums on outbound packets.
- Generating UDP or TCP checksums for hardware packet generators or lightweight offload paths.
- Verifying incoming packet checksums before payloads are committed to DMA or application buffers.

## Interfaces and Signal-Level Behavior

- Input side usually accepts streaming packet data plus sideband fields that identify checksum regions and expected insertion points.
- Output side returns the packet with inserted checksum fields or emits pass/fail metadata for verification use.
- Control registers may select protocol flavor, seed values, and whether bad packets are dropped, flagged, or passed through.

## Parameters and Configuration Knobs

- Datapath width, checksum field offset, support for pseudo-header accumulation, and pipeline depth.
- Insert versus verify operating modes and handling of odd-byte packet lengths.
- Metadata widths for packet length, protocol type, and partial-sum chaining.

## Internal Architecture and Dataflow

Most checksum offload engines maintain a running one's-complement accumulator over word-aligned data, fold carries back into the low bits, and optionally invert the result before writing it into a packet field. Practical implementations include byte enables or alignment logic so headers starting on arbitrary byte offsets can still be processed correctly. Verify paths compare the computed value against the expected field or against the protocol-specific good sum constant.

## Clocking, Reset, and Timing Assumptions

The block assumes upstream parsers identify the correct checksum region and that packet boundaries are preserved without truncation. Reset should clear partial accumulators so state from one packet cannot leak into the next after a flush or error.

## Latency, Throughput, and Resource Considerations

Checksum offload is streaming-friendly and normally sustains one input beat per cycle once the pipeline is full. Cost scales with datapath width, alignment logic, and whether the design supports multiple simultaneous partial sums for layered protocol stacks.

## Verification Strategy

- Check known-good vectors for IPv4, UDP, and TCP style packets including odd-length payloads.
- Exercise misaligned starts, short packets, zero-length payloads, and insertion at different byte offsets.
- Verify behavior on truncated or malformed packets so the pipeline does not emit believable but meaningless results.

## Integration Notes and Dependencies

This engine usually sits after a header parser and before MAC transmit or host-memory commit. Integrators should document clearly whether software is expected to preclear checksum fields, supply pseudo-header metadata, or trust this block as the sole validator for received traffic.

## Edge Cases, Failure Modes, and Design Risks

- A byte-order mistake can make every checksum wrong while still looking structurally plausible.
- If header offsets are not validated, offload logic may overwrite unrelated payload bytes.
- Some systems assume checksum verification implies packet validity even though many non-checksum protocol errors remain possible.

## Related Modules In This Domain

- packet_parser
- udp_stack
- tcp_offload_lite

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Checksum Offload Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
