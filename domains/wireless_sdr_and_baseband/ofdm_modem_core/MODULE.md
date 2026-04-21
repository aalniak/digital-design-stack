# OFDM Modem Core

## Overview

The OFDM modem core packages the core modulation and demodulation structure of an orthogonal frequency-division multiplexing waveform, bridging between subcarrier-domain symbols and time-domain multicarrier blocks. It is the architectural center of many modern SDR waveforms.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

An OFDM chain is more than just an FFT and an IFFT. It depends on subcarrier ordering, pilot placement, null carriers, guard structure, and symbol framing all being shared consistently across the transmit and receive paths. This module defines that common modem contract explicitly.

## Typical Use Cases

- Building a reusable transmit or receive modem for OFDM-based wireless links.
- Abstracting waveform-specific subcarrier structure away from surrounding application logic.
- Serving as the central frame engine in SDR prototypes and multicarrier research systems.

## Interfaces and Signal-Level Behavior

- Bit or symbol side exchanges mapped constellation symbols, pilot information, and frame-control metadata.
- Waveform side emits or consumes time-domain OFDM symbol blocks with explicit symbol boundaries.
- Control side configures FFT size, active-subcarrier map, pilot structure, and waveform profile selection.

## Parameters and Configuration Knobs

- FFT size, active-carrier count, pilot pattern, and guard-subcarrier profile.
- Symbol precision, runtime profile selection, and TX versus RX mode composition.
- Optional support for preamble symbols, variable modulation maps, and control metadata widths.

## Internal Architecture and Dataflow

The core coordinates subcarrier packing, pilot insertion or extraction, null-carrier handling, FFT or IFFT boundaries, and symbol-level framing around the lower-level transform and prefix stages. It does not replace those primitives; rather, it defines how they are arranged and interpreted for the chosen waveform. The contract should state subcarrier indexing and whether outputs are already frequency-shifted, normalized, or left in a mathematical base ordering.

## Clocking, Reset, and Timing Assumptions

The surrounding FFT, cyclic-prefix, and coding blocks must agree on symbol size and ordering exactly. Reset should clear all partial frame and symbol state so the next frame begins on a known OFDM boundary.

## Latency, Throughput, and Resource Considerations

The core itself is moderate in cost and mostly control-and-buffering oriented, but it coordinates high-rate FFT-facing datapaths. Resource use depends more on buffering and profile flexibility than on heavy arithmetic.

## Verification Strategy

- Compare packed and unpacked OFDM symbols against a waveform reference for several subcarrier maps and pilot structures.
- Check frame-boundary handling, preamble insertion or extraction, and profile switching.
- Verify TX and RX paths agree on carrier indexing and null-carrier placement.

## Integration Notes and Dependencies

This block usually sits between FEC, mapping, FFT, and prefix handling, so its framing and subcarrier conventions should be documented with those modules as one modem profile. Integrators should also note whether timing synchronization and channel estimation live inside or adjacent to this core.

## Edge Cases, Failure Modes, and Design Risks

- A subcarrier-index convention mismatch can produce healthy-looking spectra that decode poorly.
- Profile switching without a clean symbol or frame boundary can poison adjacent frames.
- If pilot and null-carrier handling are underspecified, downstream estimators and equalizers will silently disagree.

## Related Modules In This Domain

- qam_mapper_demapper
- cyclic_prefix_handler
- pilot_inserter_extractor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the OFDM Modem Core module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
