# Delta Encoder/Decoder

## Overview

Delta Encoder/Decoder converts absolute sample values into differences or reconstructs absolute values from deltas according to a defined predictor rule. It provides a low-cost decorrelation transform for structured numeric or symbol streams.

## Domain Context

Delta coding is a simple predictive transform used in many compression pipelines to reduce entropy when neighboring samples or symbols are correlated. In this domain it serves as a lightweight preconditioning stage before entropy coding or as a compact representation for monotonically varying data.

## Problem Solved

Raw values can be expensive to compress when their information content lies mostly in changes rather than absolute magnitude. A dedicated delta block makes predictor choice, wrap behavior, and reset points explicit so downstream coders see a stable transformed stream.

## Typical Use Cases

- Preconditioning image, sensor, or telemetry streams before entropy coding.
- Encoding monotonic counters or slowly varying numeric data compactly.
- Decoding delta-coded records in lightweight decompression hardware.
- Evaluating decorrelation gains before Golomb, Huffman, or arithmetic coding.

## Interfaces and Signal-Level Behavior

- Inputs are absolute values or delta values plus stream framing and mode selection for encode versus decode.
- Outputs provide transformed deltas or reconstructed absolutes with aligned valid markers.
- Control interfaces configure predictor mode, signedness, wrap or saturation behavior, and frame-reset policy.
- Status signals may expose overflow, underflow, and predictor-reset indicators.

## Parameters and Configuration Knobs

- Sample width and signedness.
- Predictor choice such as previous-sample delta or fixed baseline.
- Modulo-wrap versus saturating arithmetic policy.
- Streaming reset policy at frame or record boundaries.

## Internal Architecture and Dataflow

The block usually consists of a predictor state register, subtract or add datapath, range or wrap handling, and framing logic to reset prediction state at defined boundaries. The architectural contract should say exactly when predictor state resets, because encoder and decoder only stay aligned if their state evolution is identical.

## Clocking, Reset, and Timing Assumptions

Delta encoding assumes correlation between successive values is high enough to justify the transform. Reset and frame boundaries should both establish a documented predictor origin. If overflow wraps rather than saturates, that arithmetic interpretation must be shared by the paired decode path and by any golden models.

## Latency, Throughput, and Resource Considerations

Area cost is minimal and throughput can be one sample per cycle easily. Latency is very low. The more relevant performance issue is whether the transformed distribution actually improves compression in the intended workload rather than whether the transform itself is expensive.

## Verification Strategy

- Run encode-decode round trips across random and structured sequences.
- Check predictor reset at frame boundaries and after reset.
- Stress wraparound and signed negative-delta corner cases.
- Measure transformed entropy on representative datasets to ensure the chosen predictor is justified.

## Integration Notes and Dependencies

Delta Encoder/Decoder commonly surrounds Huffman, Golomb-Rice, Arithmetic Coder, or Run Length Codec stages. It should align with Packet Framer or file-format wrappers on where predictor state resets so independent records remain independently decodable.

## Edge Cases, Failure Modes, and Design Risks

- A reset-point mismatch between encoder and decoder silently corrupts all following samples.
- Choosing the wrong signedness or wrap convention can produce plausible but incorrect reconstructions.
- Applying delta coding to poorly correlated data can worsen compression while adding complexity.

## Related Modules In This Domain

- golomb_rice_codec
- run_length_codec
- arithmetic_coder
- entropy_adapter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Delta Encoder/Decoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
