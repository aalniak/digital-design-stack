# Golomb-Rice Codec

## Overview

Golomb-Rice Codec encodes or decodes nonnegative mapped residuals using quotient-remainder codewords parameterized by a Rice value. It provides an efficient compression primitive for residuals and other skewed integer distributions.

## Domain Context

Golomb-Rice coding is a simple entropy code well suited to geometric or low-magnitude residual distributions, making it attractive in lossless compression and predictive coding paths. In this domain it offers a lower-complexity alternative to arithmetic coding for certain structured residual streams.

## Problem Solved

Some workloads compress well with a simple parameterized code and do not justify the complexity of full adaptive entropy coding. A dedicated Golomb-Rice block makes parameter handling, signed mapping, and unary-plus-remainder formatting explicit and reusable.

## Typical Use Cases

- Encoding predictive residuals from image, audio, or telemetry compressors.
- Compressing low-magnitude signed deltas after a mapping to nonnegative integers.
- Decoding Golomb-Rice coded records in compact decompression hardware.
- Exploring low-complexity entropy coding alternatives for research datapaths.

## Interfaces and Signal-Level Behavior

- Inputs are mapped integers or raw residuals plus mode select for encode or decode and stream framing markers.
- Outputs provide bit-packed codewords or reconstructed values with valid signaling.
- Control interfaces configure Rice parameter selection, signed mapping mode, and end-of-stream flush behavior.
- Status signals often expose codeword_error, parameter_invalid, and block_done indications.

## Parameters and Configuration Knobs

- Supported Rice parameter range.
- Signed-mapping convention such as zigzag style.
- Streaming versus block-oriented framing.
- Encode-only, decode-only, or dual-mode support.

## Internal Architecture and Dataflow

The codec typically contains quotient generation or parsing, unary run handling, remainder extraction or insertion, and optional signed-value mapping. The architectural contract should state whether the Rice parameter is fixed per stream, fixed per block, or dynamic per symbol, because that choice strongly affects interoperability and compression behavior.

## Clocking, Reset, and Timing Assumptions

The module assumes values are mapped into the expected nonnegative domain unless it owns signed mapping internally. Reset clears parser and bit-pack state. If parameters change across blocks or symbols, the control timing for that change must be unambiguous to both encode and decode sides.

## Latency, Throughput, and Resource Considerations

Golomb-Rice coding can be compact and fast, though long unary quotients may create variable local latency in some designs. The main tradeoff is simplicity versus compression efficiency on distributions that may not fit a single Rice parameter well.

## Verification Strategy

- Run encode-decode round trips against a software reference across several Rice parameters and signed mappings.
- Stress values with long quotients, zero residuals, and block-boundary transitions.
- Verify bit packing and end-of-stream flush semantics explicitly.
- Measure compression performance on representative residual distributions to validate parameter policy.

## Integration Notes and Dependencies

Golomb-Rice Codec commonly follows Delta Encoder/Decoder or predictor blocks and may sit inside packetized or file-format wrappers. It should align with Packet Framer and metadata layers on how the Rice parameter is conveyed to the decoder.

## Edge Cases, Failure Modes, and Design Risks

- A mismatch in signed mapping convention breaks every decoded value while still producing superficially valid streams.
- Dynamic parameter changes that are not tightly framed can desynchronize decoder state quickly.
- Unary-run parsing under malformed streams can become a denial-of-service path if bounds are not enforced.

## Related Modules In This Domain

- delta_encoder_decoder
- run_length_codec
- arithmetic_coder
- packet_framer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Golomb-Rice Codec module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
