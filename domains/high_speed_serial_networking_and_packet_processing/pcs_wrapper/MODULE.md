# PCS Wrapper

## Overview

The PCS wrapper collects physical-coding-sublayer building blocks into a coherent shell between transceivers and higher packet logic. It typically manages encode or decode selection, alignment markers, link state, word adaptation, and status reporting for a given serial protocol profile.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Even when individual coding blocks already exist, integrating them repeatedly around a SERDES often leads to mismatched resets, missing status plumbing, and inconsistent ordering of scrambling, coding, alignment, and elasticity stages. This module defines a reusable PCS composition boundary so every link instance follows the same structure.

## Typical Use Cases

- Building custom or standards-based serial links on top of FPGA transceivers.
- Normalizing the sequence of encoding, scrambling, alignment, and monitoring stages across projects.
- Providing one place to manage link status and adaptation between line-side words and packet-side streams.

## Interfaces and Signal-Level Behavior

- Line side connects to transceiver-parallel data, recovered clocks, alignment indicators, and error counters.
- Packet side presents a data stream or framed-block interface toward MAC, transport, or custom link logic.
- Control side configures coding profile, resets, polarity options, loopback, and test modes while exposing status such as block lock and lane health.

## Parameters and Configuration Knobs

- Selected coding scheme, lane count, adaptation width, elastic-buffer options, and alignment-marker policy.
- Optional CRC or monitor features, test-pattern support, and protocol profile selection.
- Placement of CDC boundaries and whether the wrapper includes user-side packet framing or only raw coded words.

## Internal Architecture and Dataflow

The wrapper usually instantiates and orders the encode or decode blocks required by the target protocol, plus any gearboxes, elastic buffers, scramblers, and status monitors. It also arbitrates reset and training state so higher layers can rely on a single link-ready indication instead of interpreting many sub-status signals. By centralizing composition, the wrapper turns a pile of line-code helpers into a documented serial subsystem.

## Clocking, Reset, and Timing Assumptions

The module assumes the transceiver wrapper provides a stable electrical interface and that protocol-specific training sequences are either generated here or by a well-defined adjacent block. Reset needs careful staging because some PCS subblocks may require data validity or recovered-clock stability before they leave reset safely.

## Latency, Throughput, and Resource Considerations

Latency depends on which coding, buffering, and monitoring stages are enabled. Resource usage can range from modest to significant because the wrapper itself is mostly glue around potentially expensive subblocks, especially in multi-lane designs.

## Verification Strategy

- Verify subblock ordering and status gating during cold bring-up, warm reset, and line-error recovery.
- Check that the wrapper exposes a coherent contract for block lock, lane readiness, and error propagation.
- Exercise protocol-profile changes or build-time configuration variants to ensure the same wrapper API remains stable.

## Integration Notes and Dependencies

The PCS wrapper is where vendor SERDES details meet repository-level reusable line coding. Integrators should be explicit about which responsibilities stay inside the wrapper and which belong to adjacent MAC or transport blocks, especially for training patterns and alignment markers.

## Edge Cases, Failure Modes, and Design Risks

- A wrapper that hides too much status can make field debugging unnecessarily hard.
- Misordered subblocks can produce a data stream that looks active but is protocol-invalid.
- CDC or recovered-clock assumptions made in one profile may not hold for every line rate or transceiver mode.

## Related Modules In This Domain

- encoder_64b66b
- encoder_8b10b
- elastic_buffer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PCS Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
