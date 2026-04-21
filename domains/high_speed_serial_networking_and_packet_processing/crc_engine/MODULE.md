# CRC Engine

## Overview

The CRC engine computes and optionally checks cyclic redundancy check values for framed data streams. It is a reusable integrity primitive for Ethernet frame check sequences, storage protocols, private serial links, and packetized sensor transports.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

CRC logic seems straightforward until reflection rules, polynomial selection, byte ordering, initial values, and final XOR conventions diverge across protocols. Rather than duplicating slightly different LFSR code across the repository, this module provides a parameterized CRC service with explicit control over those protocol details.

## Typical Use Cases

- Appending or verifying Ethernet frame check sequences.
- Protecting board-to-board links or packet FIFOs with lightweight error detection.
- Supporting storage or telemetry formats that rely on protocol-specific CRC polynomials.

## Interfaces and Signal-Level Behavior

- Streaming data input usually carries valid, last, and optional byte-enable information so partial final words are handled correctly.
- Output side returns the final CRC value, inserts it into a packet, or flags mismatches on verify paths.
- Control inputs may select polynomial profile, seed value, reflection mode, and insert versus check operation.

## Parameters and Configuration Knobs

- Polynomial width and taps, initial seed, final XOR value, and input or output bit reflection policy.
- Datapath width, byte-enable support, and whether the engine pipelines wide parallel folds.
- Single-profile fixed-function mode versus run-time selectable CRC profiles.

## Internal Architecture and Dataflow

The engine is commonly built as a parallelized LFSR transform that updates the CRC state for each accepted data beat. Wide datapaths precompute the matrix form of many serial shifts so the design can sustain line-rate traffic without per-bit iteration. Optional insert mode appends the final remainder at packet end, while verify mode compares against a received trailer or expected terminal state.

## Clocking, Reset, and Timing Assumptions

Correct operation depends on consistent agreement about byte order and reflection policy across the entire stack. Reset or flush events must return the LFSR state to the configured seed before the next packet begins.

## Latency, Throughput, and Resource Considerations

CRC engines can be fully streaming at one word per cycle, but wide or selectable-polynomial variants trade some timing headroom for flexibility. Resource usage is primarily XOR network complexity and grows with parallel width.

## Verification Strategy

- Use published protocol vectors and software reference models for every supported polynomial profile.
- Check short packets, empty packets, partial final words, and mid-packet flush or abort cases.
- Confirm insert and verify modes agree on the same convention for seed, reflection, and final XOR.

## Integration Notes and Dependencies

This block is often shared across multiple packet paths, but reuse only works if all consumers agree on framing semantics. Designers should decide whether CRC errors cause drops, counters, replay attempts, or simply status tagging for later software inspection.

## Edge Cases, Failure Modes, and Design Risks

- Reflection and byte-order misunderstandings are a classic source of false failures.
- A packet abort without explicit CRC-state reset can poison the next frame.
- Run-time profile changes need careful gating so one frame is never processed with mixed settings.

## Related Modules In This Domain

- scrambler
- descrambler
- ethernet_mac

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the CRC Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
