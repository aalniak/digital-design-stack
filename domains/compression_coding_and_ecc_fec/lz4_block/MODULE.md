# LZ4 Block

## Overview

LZ4 Block implements one or more stages of LZ4-style compression or decompression, handling token structure, literal and match fields, and bounded streaming state. It provides a fast dictionary-based compression primitive with relatively simple format rules.

## Domain Context

LZ4 is a practical lightweight LZ-family compressor and decompressor valued for speed and simple framing rather than maximum compression ratio. In this domain it represents the fast path for systems that want meaningful size reduction with low hardware or software overhead.

## Problem Solved

Many products need compression that is much faster and simpler than Deflate while still preserving useful space savings. A dedicated LZ4 block captures token formatting, dictionary-window semantics, and literal-match sequencing without making every system rely on host software.

## Typical Use Cases

- Accelerating decompression of firmware, assets, or telemetry logs.
- Providing moderate-ratio fast compression in storage or transport pipelines.
- Supporting systems that prefer simple token-based formats over more complex entropy-coded standards.
- Evaluating hardware-friendly LZ compression in prototyping or research platforms.

## Interfaces and Signal-Level Behavior

- Inputs may include raw bytes for compression or LZ4 token streams for decompression depending on build mode.
- Outputs provide compressed tokens and payload segments or reconstructed output bytes with stream status.
- Control interfaces configure block size, dictionary-window bounds, and block-end policy.
- Status signals often expose malformed_token, window_error, and end_of_block conditions.

## Parameters and Configuration Knobs

- Compress-only, decompress-only, or dual-mode build.
- Window size and maximum match length support.
- Streaming versus independent-block mode.
- Literal and match parsing buffer depth.

## Internal Architecture and Dataflow

The block usually contains token parsing or generation, literal copy and match-copy machinery, window or history buffering, and frame-boundary control. The architectural contract should state whether it targets raw LZ4 block format, framed variants, or a subset, because interoperability and dictionary reset semantics depend on that choice.

## Clocking, Reset, and Timing Assumptions

For decompression, the module assumes the input stream obeys LZ4 token rules and declared block boundaries. Reset clears history state and should align with independent-block boundaries unless a streaming window is intentionally preserved. If compression mode uses simplified match finding, that should be called out as a design tradeoff rather than hidden behind the format name.

## Latency, Throughput, and Resource Considerations

LZ4 is attractive largely because throughput can be high with modest control complexity. Resource use is dominated by history storage and copy machinery, especially for decompression. The key performance tradeoff is often block independence versus window continuity and history memory size.

## Verification Strategy

- Run compression and decompression against a trusted LZ4 reference for supported format variants.
- Stress long literal runs, overlapping matches, and end-of-block corner cases.
- Verify history reset and independent-block behavior explicitly.
- Check malformed token handling so broken streams do not create uncontrolled copy behavior.

## Integration Notes and Dependencies

LZ4 Block typically connects to Packet Framer or storage wrappers and may coexist with stronger ratio codecs for offline use. It should be documented clearly as speed-oriented compression so system designers do not expect Deflate-like ratios from a fast-path module.

## Edge Cases, Failure Modes, and Design Risks

- Format-variant ambiguity between raw block and framed LZ4 is a common interoperability trap.
- Overlapping match-copy logic must be specified carefully or decompression may work only for easy streams.
- A simplified compressor may produce valid but unexpectedly poor compression if match-finding limits are not documented.

## Related Modules In This Domain

- packet_framer
- packet_deframer
- deflate_building_block
- run_length_codec

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the LZ4 Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
