# BCH Codec

## Overview

BCH Codec encodes or decodes binary block codes that correct multiple random bit errors within a protected block. It provides medium-strength forward error correction for storage records, packets, and reliability-sensitive configuration data.

## Domain Context

BCH coding is a configurable block-error-correction technique widely used in storage, communications, and OTP or flash-protection contexts. In this domain it fills the gap between simple Hamming protection and heavier Reed-Solomon or LDPC schemes, especially when binary block codes and bounded hardware complexity are desired.

## Problem Solved

Many systems need stronger protection than SECDED without paying for the complexity of very large or iterative decoders. A dedicated BCH block defines code parameters, syndrome handling, and correction reporting in one place so protected data paths remain interoperable and measurable.

## Typical Use Cases

- Protecting NAND, flash metadata, or on-chip nonvolatile records against multi-bit corruption.
- Adding medium-strength FEC to packet or telemetry records.
- Shielding OTP-shadow data and configuration images from storage bit errors.
- Supporting experimentation with code-rate versus correction-strength tradeoffs in binary block codes.

## Interfaces and Signal-Level Behavior

- Inputs are data blocks or codewords with framing markers and mode selection for encode or decode.
- Outputs provide encoded codewords or corrected data plus status such as corrected_error_count and decode_fail.
- Control interfaces configure code length, correction strength, shortening policy, and field polynomial selection where parameterized.
- Status signals often expose syndrome_ready, uncorrectable_error, and block_done indications.

## Parameters and Configuration Knobs

- Codeword length, message length, and correction capability t.
- Shortened-code support and block framing policy.
- Encode-only versus full encode-decode build.
- Syndrome, locator, and Chien-search datapath widths.

## Internal Architecture and Dataflow

A BCH codec usually includes parity-generation logic for encode and syndrome generation, error-locator solving, and bit-flip correction for decode. The architecture should document exactly which parameter set is implemented because BCH is a family of codes, not a single universal format, and interoperability depends on agreeing on those code parameters.

## Clocking, Reset, and Timing Assumptions

The module assumes block boundaries are explicit and that upstream storage or transport logic does not misalign codewords. Reset clears in-flight block state. If shortened codes are supported, the padding or logical-zero convention must be described clearly to avoid encoder-decoder mismatches.

## Latency, Throughput, and Resource Considerations

Area and latency grow with correction strength and codeword size, especially in decoders. Throughput is block-oriented rather than purely streaming. In practice, bounded decode latency and clear reporting of corrected versus uncorrectable blocks matter more than maximizing code-rate flexibility.

## Verification Strategy

- Compare encode and decode behavior against a trusted BCH reference across all supported parameter sets.
- Inject error patterns at, below, and above the correction limit.
- Verify shortened-code handling and block-boundary behavior.
- Check corrected-error count and uncorrectable flags for consistency with the injected error pattern.

## Integration Notes and Dependencies

BCH Codec often sits between raw storage pages or framed packets and integrity or protocol layers that need corrected payloads. It should integrate with Packet Framer or storage controllers in a way that keeps ECC bytes, payload bytes, and status metadata aligned through retries and logging.

## Edge Cases, Failure Modes, and Design Risks

- A BCH block reused with the wrong parameter set may appear functional on light tests while failing field interoperability.
- Shortened-code ambiguity is a common source of encoder-decoder mismatch.
- If corrected-versus-uncorrectable semantics are unclear, higher layers may trust payloads that should have been quarantined.

## Related Modules In This Domain

- hamming_secded
- reed_solomon_codec
- crc_family
- packet_framer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the BCH Codec module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
