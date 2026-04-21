# TDM Audio Port

## Overview

The TDM audio port moves multi-channel audio samples between the chip fabric and a serialized time-division multiplexed audio bus. It is the natural choice when many codec channels must share a small number of board pins while preserving predictable slot timing and frame alignment.

## Domain Context

Low-speed peripheral interface modules anchor configuration, service, and housekeeping traffic around the SoC. In this domain, the emphasis is deterministic register access, straightforward pin-level behavior, recoverable protocol error handling, and clean integration into control-plane fabrics rather than raw throughput.

## Problem Solved

Simple stereo-style serial audio links are not efficient once channel counts climb, and hand-built serializers often miss subtle details such as slot numbering, word alignment, inactive slot behavior, and frame sync polarity. This module packages those timing rules into a reusable port so downstream audio processing logic can operate on discrete samples instead of raw serial streams.

## Typical Use Cases

- Connecting FPGA audio pipelines to external codecs, microphone arrays, or multichannel amplifiers that expose a TDM interface.
- Bridging between internal per-channel sample streams and board-level audio backplanes used in beamforming or studio equipment.
- Capturing laboratory acoustic data where multiple synchronized channels must remain frame aligned.

## Interfaces and Signal-Level Behavior

- Fabric side usually exposes sample-valid handshakes per frame or a packed streaming interface carrying one channel sample at a time with slot metadata.
- Pin side includes bit clock, frame sync, serial data out, and serial data in for full-duplex designs.
- Status outputs typically report frame lock, slot counters, underrun, overrun, and optional mute insertion events.

## Parameters and Configuration Knobs

- Number of slots per frame, sample width, slot width, frame-sync polarity, and left- or right-justified bit alignment.
- Master versus slave clocking mode and optional support for inactive or unused slots.
- Elastic buffering depth and whether transmit or receive paths can be synthesized independently.

## Internal Architecture and Dataflow

Internally the port combines frame counters, slot counters, bit serializers and deserializers, plus small sample FIFOs that absorb phase differences between the real-time bit clock and the core processing schedule. On transmit, channel samples are mapped into slots and shifted out at bit-clock rate. On receive, incoming bits are assembled into words, tagged by slot, and forwarded only when a full frame-consistent sample is available.

## Clocking, Reset, and Timing Assumptions

When the port operates as a slave, the external bit clock and frame-sync inputs are asynchronous and need careful capture. Reset should reinitialize slot counters to a known frame boundary so the first valid frame after enable is not mis-numbered.

## Latency, Throughput, and Resource Considerations

The datapath is narrow but timing sensitivity can be high because the bit clock may run at many multiples of the per-channel sample rate. Resource use scales mostly with buffering and channel-count support rather than arithmetic complexity.

## Verification Strategy

- Verify transmit and receive operation for several slot counts, word widths, and justification modes.
- Stress underrun and overrun behavior and confirm whether muted, zero-filled, or stale data is inserted under fault conditions.
- Check long-run frame alignment to ensure channel order does not slip after resets, pauses, or missing clocks.

## Integration Notes and Dependencies

This module often sits between codec-facing pins and internal mixers, beamformers, or sample-rate conversion blocks. System integration should define who owns audio clocks, how channel maps are documented, and whether software can reconfigure framing without disrupting active streams.

## Edge Cases, Failure Modes, and Design Risks

- A one-bit alignment error can shift every channel sample and remain difficult to diagnose from software alone.
- Channel-map mismatches across transmitters and receivers can swap microphones or speakers in subtle ways.
- If buffering policy is unclear, occasional underflow events may produce audible artifacts or invalidate beamforming assumptions.

## Related Modules In This Domain

- i2s_interface
- pdm_interface
- spdif_interface

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the TDM Audio Port module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
