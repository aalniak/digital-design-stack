# TDM Audio RX or TX

## Overview

The TDM audio RX or TX module receives or transmits multichannel serial audio over a time-division-multiplexed link, bridging board-level audio transport into the internal sample fabric. It is the multichannel serial-audio counterpart to I2S.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

When many audio channels must share a small set of pins, TDM transport is common, but the slot structure and frame alignment should not leak into every processing block. This module provides that reusable interface layer.

## Typical Use Cases

- Connecting multichannel codecs, microphone arrays, or amplifiers over TDM audio links.
- Providing reusable multichannel serial-audio ingress or egress in embedded audio systems.
- Bridging board-level audio transport to internal channelized sample processing.

## Interfaces and Signal-Level Behavior

- Serial side connects to bit clock, frame sync, and serial data in receive or transmit direction.
- Fabric side emits or consumes sample frames with explicit slot or channel ordering.
- Control side configures slot width, sample width, master-slave mode, and frame structure.

## Parameters and Configuration Knobs

- Channel or slot count, sample width, slot width, and master versus slave mode.
- FIFO depth, bit-clock ratio, and underflow or overflow policy.
- Clock-domain handling and optional mute or zero-fill behavior on missing data.

## Internal Architecture and Dataflow

The module serializes or deserializes audio samples according to the configured slot and frame timing, buffering between the serial timing domain and the internal sample stream. It tracks slot position so the fabric sees a clear channel ordering. The contract should state whether inactive or unused slots are discarded, zero-filled, or surfaced as explicit metadata.

## Clocking, Reset, and Timing Assumptions

Clock ownership and slot structure must match the attached device or bus standard exactly. Reset should return the transport to a clean frame boundary and clear buffered audio words.

## Latency, Throughput, and Resource Considerations

The transport logic is moderate in complexity and mainly timing- and CDC-oriented rather than arithmetic-heavy. Resource use grows with slot count and any buffering included.

## Verification Strategy

- Check slot ordering, framing, and sample extraction against known TDM waveforms in RX and TX modes.
- Verify master-slave timing, reset behavior, and underflow or overflow policy.
- Confirm fabric-side channel-frame grouping remains correct under CDC and burst conditions.

## Integration Notes and Dependencies

This block should be documented with the connected codec or array slot map and clocking assumptions. Integrators should also note whether the internal channel order follows slot order directly or some remapped convention.

## Edge Cases, Failure Modes, and Design Risks

- A slot-order mismatch can subtly scramble multichannel systems even when single-channel testing passes.
- Slave-mode timing assumptions may fail only with real external clock tolerance.
- If unused-slot handling is unclear, downstream channel counts may drift from expectations.

## Related Modules In This Domain

- i2s_rx_tx
- audio_fifo
- microphone_beamformer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the TDM Audio RX or TX module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
