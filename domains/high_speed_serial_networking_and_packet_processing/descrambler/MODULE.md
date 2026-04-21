# Descrambler

## Overview

The descrambler reverses protocol-defined data scrambling on received serial or parallel streams so downstream decoders and packet logic see the original payload symbols. It is generally paired with a matching scrambler on the transmit path to control spectral content and transition density on high-speed links.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Many serial standards whiten the transmitted bit stream to improve clock recovery and EMI behavior, but that means receive logic must reconstruct the original data with exact alignment to the same polynomial and reset convention. This module makes that transformation explicit and reusable instead of burying it inside a PHY-specific wrapper.

## Typical Use Cases

- Recovering payload bits on private SERDES links or Ethernet-like transports that use self-synchronous scrambling.
- Decoding storage or backplane protocols that define deterministic scrambler reset points.
- Separating line-code conditioning logic from higher-level parsers during verification and debug.

## Interfaces and Signal-Level Behavior

- Input side accepts serialized or parallelized data words plus framing information that identifies where scrambler state may reset or re-seed.
- Output side emits descrambled data in the same width and timing domain for downstream decode blocks.
- Status side may report loss of alignment, illegal reset timing, or diagnostic snapshots of internal state for debug.

## Parameters and Configuration Knobs

- Scrambler polynomial, self-synchronous versus synchronous mode, and state reset policy.
- Parallel datapath width and whether byte-enable or control-symbol masks must bypass descrambling.
- Optional pipelining or lane-wise operation for bonded links.

## Internal Architecture and Dataflow

The core is usually an LFSR-based transform applied either serially or in a parallelized matrix form. In self-synchronous modes, output data also influences later state, while synchronous modes rely only on a seeded internal register. Practical designs often mask out control characters or reinitialize at frame boundaries according to the protocol so payload data is restored correctly without corrupting non-data symbols.

## Clocking, Reset, and Timing Assumptions

The descrambler must start from the same state or reset points assumed by the transmitter. If the surrounding link can lose lane alignment, higher-level logic needs to coordinate re-seeding before the descrambler output is considered trustworthy again.

## Latency, Throughput, and Resource Considerations

The transform is lightweight and can often run at line-rate word cadence, but wide parallel versions add XOR depth that may require pipelining. Latency is usually fixed and small compared with link buffering.

## Verification Strategy

- Cross-check against a software reference model and the matching transmit scrambler across long random sequences.
- Verify reset and re-seed behavior at packet boundaries, idles, and alignment events.
- Confirm control symbols or masked bytes are preserved exactly when the protocol requires bypass paths.

## Integration Notes and Dependencies

This block normally sits immediately after lane alignment and before decode, CRC, or packet parsing stages. Debug visibility is especially valuable here because scrambling errors can make every downstream block appear broken even when the root cause is only an LFSR-state mismatch.

## Edge Cases, Failure Modes, and Design Risks

- A single state-initialization mistake can corrupt every received byte while preserving realistic transition density.
- Mixing control characters into the descrambler path when they should bypass it can break lane control and packet framing.
- Multi-lane systems may need per-lane state management, not one shared descrambler across bonded data.

## Related Modules In This Domain

- scrambler
- encoder_64b66b
- pcs_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Descrambler module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
