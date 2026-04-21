# Hamming SECDED

## Overview

Hamming SECDED encodes data words with parity bits that enable single-error correction and double-error detection on decode. It provides lightweight ECC protection for moderate-width words and latency-sensitive control data.

## Domain Context

Hamming SECDED is the classic low-cost protection scheme for words and small records where single-bit correction and double-bit detection are sufficient. In this domain it is the simplest serious ECC building block and often the baseline reliability layer for memories, configuration state, and narrow records.

## Problem Solved

Many systems need more reliability than parity alone but do not justify block-oriented BCH or Reed-Solomon machinery. A dedicated SECDED block standardizes bit placement, syndrome decoding, and error-status reporting so protected words can be handled uniformly.

## Typical Use Cases

- Protecting SRAM or register-file words in a small or medium-width datapath.
- Adding lightweight ECC to control records, descriptors, or configuration tables.
- Shielding OTP shadows or boot metadata where low overhead and low latency matter.
- Serving as a baseline ECC primitive alongside stronger codes used elsewhere in the system.

## Interfaces and Signal-Level Behavior

- Inputs are data words or protected codewords plus mode selection for encode or decode.
- Outputs provide encoded words or corrected payload plus single_error and double_error status.
- Control interfaces usually configure word width or profile select when the block supports several widths.
- Status signals often expose syndrome_valid, corrected_bit_index, and uncorrectable flags.

## Parameters and Configuration Knobs

- Supported data widths and parity placement profile.
- Encode-only, decode-only, or dual-mode support.
- Optional pipelining for memory-path timing closure.
- Whether corrected-bit index or syndrome is externally visible.

## Internal Architecture and Dataflow

The block typically contains parity-generation XOR networks, syndrome computation, and correction selection logic. The important contract is the exact bit ordering of data and parity positions, because a perfectly valid Hamming decoder will still fail if paired with a different placement convention.

## Clocking, Reset, and Timing Assumptions

SECDED assumes the expected error model is dominated by isolated single-bit faults rather than bursts. Reset clears pipeline state only; there is usually no persistent block context. If syndrome or corrected-bit information is exposed, the documentation should note whether it is intended for diagnostics only or for active system policy.

## Latency, Throughput, and Resource Considerations

Area cost is low and latency can often be one cycle or purely combinational for modest widths. Throughput is typically one word per cycle. The key performance tradeoff is timing closure on wide XOR trees versus the low-latency expectation of memory or control-path users.

## Verification Strategy

- Check encode and decode against a software SECDED reference for every supported width.
- Inject all single-bit errors and representative double-bit errors.
- Verify corrected versus detected-only status semantics and corrected payload accuracy.
- Confirm parity-bit placement and bit ordering are documented and tested consistently.

## Integration Notes and Dependencies

Hamming SECDED often sits directly around memories, descriptor paths, or configuration stores and may coexist with stronger BCH or Reed-Solomon protection for larger records. It should integrate with logging or scrubbing logic that distinguishes correctable from uncorrectable events.

## Edge Cases, Failure Modes, and Design Risks

- Using SECDED where burst errors dominate can create a false sense of protection.
- Bit-order mismatches between encoder and decoder are deceptively easy to introduce.
- Treating double-error detect as recoverable without higher-level redundancy can corrupt state silently.

## Related Modules In This Domain

- bch_codec
- crc_family
- reed_solomon_codec
- packet_framer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Hamming SECDED module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
