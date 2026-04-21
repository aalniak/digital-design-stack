# 64b/66b Encoder

## Overview

The 64b/66b encoder transforms 64-bit payload words into 66-bit blocks with sync headers for efficient high-speed transmission. It is commonly used where low coding overhead and robust block delineation are more important than the strong run-length guarantees offered by heavier schemes like 8b/10b.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Raw payload streams need enough structure for block alignment and control indication on the wire, but excessive coding overhead wastes link bandwidth. This module applies the compact 64b/66b framing transform so transceivers or PCS layers can distinguish data blocks from control blocks while leaving payload efficiency high.

## Typical Use Cases

- Preparing Ethernet-like or private backplane traffic for high-speed serial lanes.
- Feeding a PCS wrapper that performs additional scrambling and lane adaptation.
- Building custom links that need low-overhead block framing with explicit sync headers.

## Interfaces and Signal-Level Behavior

- Input side accepts 64-bit data payloads or control block payloads plus metadata identifying block type.
- Output side emits 66-bit encoded blocks or a width-adapted equivalent toward the next line-coding stage.
- Status outputs may flag invalid control formatting or unsupported block-type requests.

## Parameters and Configuration Knobs

- Block-type support set, datapath adaptation width, and optional pipelining.
- Whether control-block mapping is fixed to a particular protocol subset or left generic.
- Integration options for downstream scrambler coupling and idle generation.

## Internal Architecture and Dataflow

At minimum the encoder prepends a two-bit sync header and maps requested control semantics into the remaining 64-bit payload field according to the selected standard profile. In many designs it also coordinates with a scrambler and optional block scheduler that chooses between data, idles, and ordered-set style control blocks. Because the transformation is mostly structural, correctness hinges on block-type mapping and ordering rather than complex math.

## Clocking, Reset, and Timing Assumptions

The upstream source must only request control block encodings that the chosen profile supports. Reset should place the encoder into a state where the first emitted blocks are valid alignment-friendly idles or known-good control patterns if the link requires that for bring-up.

## Latency, Throughput, and Resource Considerations

Coding overhead is low at only two extra bits per 64 payload bits, so bandwidth efficiency is high. Logic depth is modest and typically dominated by control-block formatting and any width adaptation around the core transform.

## Verification Strategy

- Verify data and control block encodings against a software or standards-based reference table.
- Check block sequencing through reset, idle insertion, and packet boundaries.
- Confirm illegal control requests are either blocked or flagged rather than silently mis-encoded.

## Integration Notes and Dependencies

The encoder usually feeds a scrambler, gearbox, or transceiver-adaptation stage. Integrators should define clearly whether this block owns idle generation or whether a higher scheduler determines when control versus data blocks are sent.

## Edge Cases, Failure Modes, and Design Risks

- Incorrect control-block formatting can preserve alignment while carrying the wrong semantic meaning.
- If block scheduling across reset is not deterministic, receiver alignment or training may become flaky.
- Width adaptation around 66-bit outputs is easy to mishandle in downstream gearboxes.

## Related Modules In This Domain

- scrambler
- gearbox
- pcs_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the 64b/66b Encoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
