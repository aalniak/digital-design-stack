# LDPC Codec

## Overview

The LDPC codec provides low-density parity-check encoding and iterative decoding for high-performance coded communication links. It is a heavy but central modern FEC block in many wireless systems.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Modern links often rely on LDPC for strong coding gain, but those gains require exact parity-check structure, soft-metric conventions, and iterative decode control. This module packages that complex codec stage so the rest of the modem can treat it as a defined coding service.

## Typical Use Cases

- Encoding or decoding data channels in modern wireless or high-rate SDR links.
- Providing strong forward-error correction with soft-information support.
- Serving as a reusable modern FEC core in baseband systems.

## Interfaces and Signal-Level Behavior

- Encode side accepts payload blocks and emits systematic or encoded codewords according to the selected profile.
- Decode side accepts soft metrics or coded bits plus block-valid control and returns decoded payloads with status.
- Control side configures code profile, iteration limits, and early-stop or syndrome policy.

## Parameters and Configuration Knobs

- Code profile count, block size, soft-metric width, and maximum iteration count.
- Systematic versus encoded output mode, puncturing or shortening support, and syndrome-report detail.
- Runtime profile selection and status output format.

## Internal Architecture and Dataflow

The encoder generates parity from the selected sparse parity-check structure, while the decoder iteratively exchanges messages between variable and check nodes or equivalent schedule elements until convergence or iteration limit. The contract should define exactly what input metric representation is expected, how early termination is signaled, and what constitutes decode success or failure.

## Clocking, Reset, and Timing Assumptions

The selected code profile, puncturing, and soft-metric scaling must match the waveform and demapper exactly. Reset should clear all iterative state and partial block context before a new codeword begins.

## Latency, Throughput, and Resource Considerations

LDPC decoding is one of the heaviest baseband blocks due to large memories and iterative updates, while encoding is comparatively lighter. Resource use scales with code size, iteration count, and parallelism strategy.

## Verification Strategy

- Compare encode and decode behavior against a reference LDPC implementation across profiles and SNR conditions.
- Check soft-metric scaling, early-stop logic, and decode-failure semantics.
- Verify profile switching and reset behavior across codeword boundaries.

## Integration Notes and Dependencies

This block usually sits near demappers, HARQ buffers, and framers, so block size and soft-metric conventions should be documented with those consumers. Integrators should also note whether the codec is configured once at startup or can switch profiles dynamically.

## Edge Cases, Failure Modes, and Design Risks

- Soft-metric scaling mismatches can severely degrade performance while producing no obvious logic error.
- If profile switching is not block synchronized, entire codewords may be decoded against the wrong parity matrix.
- Decode status semantics that are too vague can make higher-layer retransmission policy unreliable.

## Related Modules In This Domain

- harq_buffer
- equalizer_core
- interleaver

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the LDPC Codec module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
