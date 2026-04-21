# Elastic Buffer

## Overview

The elastic buffer absorbs short-term rate or phase differences between recovered-line clocks and the internal packet-processing clock domain. It is a foundational link-conditioning block for SERDES receive paths, PCS layers, and lane-bonded transports where local clock tolerance cannot be assumed to be zero.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Line-side data often arrives with frequency offset, burstiness, or alignment-marker insertion rules that do not map cleanly onto the consumer clock. Without elasticity, minor ppm differences accumulate into overflow or underflow. This module provides a controlled slip region that converts line cadence into a stable internal stream while preserving framing and diagnostic visibility.

## Typical Use Cases

- Bridging recovered clock domains into packet-processing clocks on high-speed receivers.
- Absorbing idles and alignment-marker variation in PCS or proprietary serial links.
- Decoupling lane-level deserialization from shared downstream processing in bonded interfaces.

## Interfaces and Signal-Level Behavior

- Write side usually accepts decoded words plus control markers that indicate idles, commas, or alignment symbols.
- Read side presents a regular stream or packet-aware output under a local consumer clock.
- Status outputs report fill level, slip events, impending overflow, underflow, and sometimes rate-match insert or delete counts.

## Parameters and Configuration Knobs

- Depth in words, programmable high and low watermarks, and optional packet-boundary awareness.
- Support for idle delete or insert operations, marker-based slip policy, and lane-specific instantiation.
- Choice of synchronous, mesochronous, or asynchronous implementation style.

## Internal Architecture and Dataflow

Most elastic buffers are specialized FIFOs augmented with policy logic that decides when certain non-payload symbols may be dropped or duplicated to maintain safe occupancy. In simple asynchronous uses the block behaves like a conventional dual-clock FIFO. In protocol-aware uses it additionally tracks which symbols are safe to manipulate so packet payload is never altered while clock compensation still occurs.

## Clocking, Reset, and Timing Assumptions

Any logic that inserts or removes symbols must only do so at protocol-approved locations such as idles or ordered sets. Reset needs to establish a known occupancy and often must wait for link alignment before asserting data-valid downstream.

## Latency, Throughput, and Resource Considerations

The block should sustain line-rate operation continuously. Resource cost is mostly storage depth plus pointer and occupancy logic; packet-aware compensation features add modest control complexity but little arithmetic.

## Verification Strategy

- Stress ppm mismatch scenarios that slowly force occupancy toward both overflow and underflow extremes.
- Verify packet payload is never altered while only permitted compensation symbols are inserted or deleted.
- Check recovery after reset, lane re-lock, and malformed control-symbol sequences.

## Integration Notes and Dependencies

Elastic buffers usually sit close to PHY or PCS boundaries and therefore interact strongly with recovered clocks, deskew logic, and link status gating. Downstream blocks should treat data as invalid until the buffer declares itself synchronized and safely occupied.

## Edge Cases, Failure Modes, and Design Risks

- A compensation event in the middle of payload data creates corruption that higher layers may blame on unrelated parsers.
- Occupancy thresholds that are too narrow can oscillate between insert and delete events.
- If fill-level telemetry is not exposed, intermittent ppm issues become difficult to debug on hardware.

## Related Modules In This Domain

- aurora_style_link
- pcs_wrapper
- ptp_timestamp_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Elastic Buffer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
