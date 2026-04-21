# CRC Family

## Overview

CRC Family computes or checks cyclic redundancy codes across streamed or block-formatted data using one or more supported generator polynomials. It provides configurable error-detection coverage for packetized and storage-oriented pipelines.

## Domain Context

CRC logic is the lightweight integrity primitive used almost everywhere in digital transport and storage framing. In this domain it provides fast error-detection coverage around packets, records, and internal framed payloads without claiming full cryptographic authenticity.

## Problem Solved

Transport and storage systems routinely need strong accidental-error detection with well-known polynomial profiles. A dedicated CRC block avoids reimplementing polynomial-specific logic in every framer, while keeping init, reflection, and final-xor semantics explicit.

## Typical Use Cases

- Appending and checking CRCs on packets, telemetry frames, or storage records.
- Supporting multiple standards that each expect a specific CRC polynomial and reflection rule.
- Providing lightweight integrity checks inside non-cryptographic internal protocols.
- Enabling hardware offload of per-frame CRC calculation for high-rate interfaces.

## Interfaces and Signal-Level Behavior

- Inputs typically include payload stream, frame-start and frame-end markers, and mode selection for generate or check.
- Outputs provide CRC value, check pass or fail, and frame completion status.
- Control interfaces configure polynomial profile, seed, reflection, and final-xor mode.
- Status signals often expose crc_mismatch, frame_error, and configuration-valid indicators.

## Parameters and Configuration Knobs

- Supported polynomial set and CRC widths.
- Streaming versus memory-block update mode.
- Parallel datapath width and folding strategy.
- Generate-only, check-only, or dual-mode support.

## Internal Architecture and Dataflow

CRC logic generally uses LFSR-style update networks, optional parallel folding, and frame-state control. The contract should document the exact standard profile for each supported mode, because CRC mismatches are often caused by init, reflection, or final-xor disagreement rather than the polynomial alone.

## Clocking, Reset, and Timing Assumptions

The block assumes frame boundaries are explicit and byte ordering is known. Reset clears running CRC state. If partial frames or chained segments are supported, the continuation semantics should be described clearly to avoid accidental mismatch between hardware and software tooling.

## Latency, Throughput, and Resource Considerations

CRC blocks are usually compact and fast, especially when customized to a small polynomial set. Throughput scales with parallel update width. The more important practical performance issue is clean behavior under backpressure and variable frame lengths rather than absolute area.

## Verification Strategy

- Validate each supported CRC profile against known vectors and standard examples.
- Check zero-length frames, odd lengths, and continuation or segmented-frame modes if supported.
- Verify generate and check modes against the same framing semantics.
- Stress backpressure and start-end marker alignment so CRC state updates only on intended payload bytes.

## Integration Notes and Dependencies

CRC Family is commonly wrapped by Packet Framer, Packet Deframer, and storage-record builders. It should remain clearly labeled as accidental-error detection, not security authentication, so it is not misused where adversarial integrity is required.

## Edge Cases, Failure Modes, and Design Risks

- Many CRC interoperability failures come from reflection and seed mismatch rather than the polynomial itself.
- If frame markers are misaligned by one beat, the computed CRC may be consistently wrong in ways that are hard to spot.
- Treating CRC success as proof of trusted origin is a category error that can weaken system design.

## Related Modules In This Domain

- packet_framer
- packet_deframer
- bch_codec
- hamming_secded

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the CRC Family module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
