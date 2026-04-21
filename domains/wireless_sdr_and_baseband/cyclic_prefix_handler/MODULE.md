# Cyclic Prefix Handler

## Overview

The cyclic prefix handler inserts or removes cyclic prefixes around OFDM symbols or similar block waveforms according to the selected waveform profile. It is a structural framing block rather than a modulation kernel.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Multicarrier systems rely on cyclic prefixes for channel resilience, but prefix length, symbol timing, and block boundaries must be handled exactly for interoperability. This module centralizes that framing step so OFDM chains stay consistent.

## Typical Use Cases

- Appending cyclic prefixes on OFDM transmit paths.
- Removing prefixes and recovering FFT-ready symbols on OFDM receive paths.
- Providing reusable symbol-boundary logic in multicarrier systems.

## Interfaces and Signal-Level Behavior

- Input side accepts time-domain OFDM symbol blocks with explicit block framing.
- Output side emits prefixed or deprefixed symbols and associated timing markers.
- Control side configures prefix length, symbol size, and waveform profile.

## Parameters and Configuration Knobs

- Symbol length, prefix length, sample width, and TX versus RX mode.
- Runtime waveform profile selection, buffering depth, and block-boundary signal style.
- Optional support for several prefix lengths or special-symbol variants.

## Internal Architecture and Dataflow

In transmit mode the handler copies the configured suffix portion of each symbol to its front; in receive mode it discards the configured prefix samples and realigns the symbol block for later FFT processing. The contract should state exactly when symbols are considered complete and how any optional short or long prefix variants are represented.

## Clocking, Reset, and Timing Assumptions

The block assumes the surrounding chain already agrees on symbol size and sample ordering. Reset should clear partial symbol buffers and restart on a clean OFDM boundary.

## Latency, Throughput, and Resource Considerations

The logic is mostly buffering and address control with modest cost, but correct symbol framing is crucial to the whole modem. Resource use depends on symbol size and support for multiple prefix variants.

## Verification Strategy

- Compare prefixed and deprefixed symbol streams against a waveform reference.
- Check several prefix lengths, symbol-boundary markers, and reset behavior.
- Verify that RX-mode alignment is correct for later FFT processing.

## Integration Notes and Dependencies

This block usually sits between IFFT or FFT engines and other OFDM framing logic, so symbol-size and prefix-length conventions should be documented with those neighbors. Integrators should also note whether special preamble symbols are handled here or elsewhere.

## Edge Cases, Failure Modes, and Design Risks

- A one-sample prefix-length mistake breaks the effective orthogonality of the OFDM chain.
- Mode switching between prefix variants can corrupt whole symbols if not boundary synchronized.
- If block-boundary markers are ambiguous, downstream FFT stages will consume misaligned data.

## Related Modules In This Domain

- ifft_engine
- fft_engine
- ofdm_modem_core

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Cyclic Prefix Handler module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
