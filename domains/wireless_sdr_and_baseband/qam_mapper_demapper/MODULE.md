# QAM Mapper or Demapper

## Overview

The QAM mapper or demapper converts between coded bits and constellation symbols for QAM or related modulation alphabets. It is one of the most central modulation stages in the baseband chain.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Bit-to-symbol mapping and symbol-to-bit likelihood recovery define the interface between coding and waveform generation, but constellation scaling, Gray ordering, and soft-metric conventions must be exact to preserve performance. This module packages that modulation boundary.

## Typical Use Cases

- Mapping coded bits into modulation symbols on transmit.
- Generating hard or soft bit metrics from received symbols on receive.
- Providing reusable constellation conversion in SDR and baseband systems.

## Interfaces and Signal-Level Behavior

- Bit side accepts coded bits or emits hard or soft bit decisions.
- Symbol side emits or consumes complex constellation points.
- Control side selects modulation order, normalization mode, and TX versus RX behavior.

## Parameters and Configuration Knobs

- Supported modulation orders, symbol precision, soft-metric width, and Gray-map profile.
- Constellation normalization, clipping policy, and runtime mode switching.
- Hard-decision versus soft-output support and LLR scaling representation.

## Internal Architecture and Dataflow

In mapping mode the block groups input bits according to the selected modulation order and outputs the corresponding normalized constellation point. In demapping mode it computes hard decisions or soft metrics from received symbols relative to the expected constellation. The contract should define the exact bit order inside each symbol, the normalization convention, and whether soft outputs are signed LLR-like values or another metric type.

## Clocking, Reset, and Timing Assumptions

The coding, interleaving, and decoder stages must share the documented bit order and metric scaling. Reset should clear any staged bit grouping or symbol-context state before a new frame begins.

## Latency, Throughput, and Resource Considerations

Mapping is light, while demapping with soft outputs is moderate in cost due to distance computations. Resource use depends on constellation order and whether soft metrics are supported at full throughput.

## Verification Strategy

- Compare mapped constellations and demapped hard or soft outputs against a reference modem implementation.
- Check Gray ordering, normalization, and runtime modulation-order switching.
- Verify LLR sign and scale conventions across several SNR and equalization states.

## Integration Notes and Dependencies

This block usually sits between interleaving or coding and waveform generation or detection, so bit ordering and metric conventions should be documented with those neighbors. Integrators should also note whether equalized symbols are assumed at the demapper input.

## Edge Cases, Failure Modes, and Design Risks

- A Gray-map mismatch can degrade decoder performance badly while the constellation still looks correct.
- Soft-metric sign errors are especially damaging and not obvious from hard-decision tests.
- Runtime modulation-order switches without frame boundaries can misgroup bits across symbols.

## Related Modules In This Domain

- equalizer_core
- ldpc_codec
- ofdm_modem_core

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the QAM Mapper or Demapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
