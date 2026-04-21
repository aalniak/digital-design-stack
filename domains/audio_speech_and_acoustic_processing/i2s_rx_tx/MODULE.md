# I2S RX or TX

## Overview

The I2S RX or TX module receives or transmits stereo or multichannel serial audio according to the Inter-IC Sound timing convention. It is a foundational audio-interface block for codecs and converters.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

Audio converters and codecs often speak I2S, but the serial framing, word alignment, and clock ownership details should not leak into every audio pipeline. This module provides that reusable interface boundary.

## Typical Use Cases

- Connecting FPGA or SoC audio pipelines to external codecs and DACs or ADCs.
- Providing a standard serial-audio ingress or egress for embedded audio devices.
- Serving as reusable transport glue at the edge of audio processing chains.

## Interfaces and Signal-Level Behavior

- Serial side connects to bit clock, word select, and serial data lines in receive or transmit direction.
- Fabric side emits or consumes sample frames with channel ordering and valid timing.
- Control side configures master versus slave mode, word width, and optional framing details.

## Parameters and Configuration Knobs

- Sample width, channel count support, master or slave mode, and FIFO depth.
- Bit-clock ratio, word alignment policy, and stereo versus TDM-like extension behavior if supported.
- Clock-domain bridging and underflow or overflow policy.

## Internal Architecture and Dataflow

The module serializes or deserializes sample words according to bit-clock and word-select timing, buffering between the serial edge domain and the fabric audio stream. The contract should define exact channel ordering, left-right phase, and whether the module owns the clocks or follows an external source.

## Clocking, Reset, and Timing Assumptions

Master-slave mode and bit-clock relationship must be selected correctly for the attached codec or converter. Reset should return the serial interface to a known idle state and clear buffered samples.

## Latency, Throughput, and Resource Considerations

The arithmetic cost is low, but reliable timing and CDC handling are central. Resource use is mainly shift logic and small FIFOs.

## Verification Strategy

- Check serial framing and channel ordering against known I2S waveforms in both RX and TX modes.
- Verify master-slave timing, reset behavior, and underflow or overflow policy.
- Confirm fabric-side frame grouping and metadata remain correct across CDC boundaries.

## Integration Notes and Dependencies

This block sits at the boundary between physical audio devices and digital processing, so clock ownership and channel order should be documented with it. Integrators should also note whether audio samples are signed, left-justified, or otherwise specially formatted internally.

## Edge Cases, Failure Modes, and Design Risks

- A left-right phase or bit-order mistake can sound like subtle channel corruption rather than obvious failure.
- Slave-mode CDC mistakes may only appear on hardware with real clock tolerance.
- Underflow policy that is not explicit can create audible glitches during low-traffic conditions.

## Related Modules In This Domain

- spdif_rx_tx
- tdm_audio_rx_tx
- audio_fifo

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the I2S RX or TX module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
