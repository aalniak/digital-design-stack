# Packet Deframer

## Overview

Packet Deframer parses incoming packetized records, extracts payload and metadata fields, and presents a normalized internal stream to downstream decode or consumer logic. It is the structural inverse of a packet framer.

## Domain Context

Packet deframing is the receive-side structural layer that turns serialized or block-level packet records back into payload plus metadata for decoders and consumers. In this domain it is where transport framing, integrity sidebands, and payload boundaries become explicit internal events.

## Problem Solved

Compression and ECC engines often rely on clean block boundaries and sideband fields such as lengths, CRCs, or code parameters. A dedicated deframer keeps those parsing rules explicit and reusable rather than embedding them in each downstream block.

## Typical Use Cases

- Parsing compressed or ECC-protected packet records before decode.
- Separating payload, length, and status fields from transport-specific encapsulation.
- Checking framing correctness before expensive decompression or error correction work begins.
- Normalizing several packet sources into one internal payload interface.

## Interfaces and Signal-Level Behavior

- Inputs are packet bytes or words plus start and end markers or a lower-layer framing indication.
- Outputs provide payload stream, extracted metadata, and frame-valid or frame-error status.
- Control interfaces configure expected header fields, length policy, and optional CRC or trailer handling ownership.
- Status signals often expose header_error, length_error, payload_valid, and frame_done indications.

## Parameters and Configuration Knobs

- Header and trailer format options.
- Maximum packet length and metadata field widths.
- Streaming versus buffered payload emission.
- Ownership of CRC checking or handoff to a separate integrity block.

## Internal Architecture and Dataflow

A packet deframer usually contains header parser, length tracker, payload selector, metadata extraction, and trailer or integrity-field handling. The architectural contract should say exactly what framing standard or internal packet shape it expects, because downstream compressors and ECC blocks often depend on precise field interpretation.

## Clocking, Reset, and Timing Assumptions

The module assumes upstream transport delivers complete ordered packet bytes and trustworthy packet boundaries or escape processing. Reset clears partial parse state. If malformed frames are tolerated for diagnostics, the deframer should document which fields remain trustworthy after an error and which do not.

## Latency, Throughput, and Resource Considerations

Area cost is modest, with throughput usually tied to packet input width. Latency depends on how much of the header must be parsed before payload release. The key performance question is often whether payload can stream through early or only after full-frame validation.

## Verification Strategy

- Validate parsing against the intended packet format using nominal and malformed frame cases.
- Stress truncated packets, bad lengths, and trailer mismatches.
- Check metadata alignment so payload consumers receive sideband fields that truly belong to the same frame.
- Verify interaction with downstream decoders when frame_error is asserted mid-payload.

## Integration Notes and Dependencies

Packet Deframer typically precedes LZ, Huffman, CRC, or ECC decode paths and should align with Packet Framer on every field and length convention. It may also interact with transport or DMA layers that own outer framing but not compression-specific record structure.

## Edge Cases, Failure Modes, and Design Risks

- If header parsing and payload release semantics are ambiguous, downstream blocks may consume data from frames that should have been rejected.
- A silent length off-by-one can corrupt whole decode chains while looking like an algorithm bug elsewhere.
- Mixing transport framing and compression record framing in one block can make reuse brittle.

## Related Modules In This Domain

- packet_framer
- crc_family
- lz4_block
- deinterleaver

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Packet Deframer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
