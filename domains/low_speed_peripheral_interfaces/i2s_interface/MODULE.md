# I2s Interface

## Overview

i2s_interface handles I2S-style serial audio transport, including bit clocking, word select framing, sample packing, and host-facing buffering. It is the audio-sample serial link primitive in the low-speed interface layer.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

Audio serial links seem regular, but sample width, alignment, clock mastership, and channel framing quickly create integration bugs if not specified tightly. i2s_interface packages those choices into one reusable contract.

## Typical Use Cases

- Send or receive stereo audio samples between codecs and digital logic.
- Bridge audio sample buffers to serial audio peripherals.
- Provide a simple synchronous audio link for embedded multimedia pipelines.

## Interfaces and Signal-Level Behavior

- Bus-facing signals typically include bit clock, word select or frame sync, serial data in, and serial data out depending on mode.
- Host-facing controls include sample data push or pop, format configuration, and status.
- Status often reports sample available, underrun, overrun, frame alignment, and clock mode.

## Parameters and Configuration Knobs

- SAMPLE_WIDTH sets active sample size.
- CHANNEL_MODE selects stereo or other supported layouts.
- MASTER_MODE_EN defines whether the core can generate clocks.
- FIFO_DEPTH sizes host-facing buffering.
- JUSTIFICATION_MODE defines left-justified, I2S, or limited supported frame alignment variants if configurable.

## Internal Architecture and Dataflow

An I2S interface usually contains serial shift registers, sample pack and unpack logic, frame boundary detection, and optional internal FIFOs. The contract needs to state clearly which side owns the clocks and how sample widths map into the serial frame.

## Clocking, Reset, and Timing Assumptions

The core must document supported alignment conventions and whether clocks are generated or only consumed. Reset should clear partial frame state so stale bits cannot contaminate the next sample.

## Latency, Throughput, and Resource Considerations

The external link rate is usually far below the system clock, so usability depends more on FIFO sizing, framing correctness, and underrun or overrun behavior than on raw internal timing.

## Verification Strategy

- Check transmit and receive paths for supported sample widths and alignments.
- Exercise master and slave clocking modes if both exist.
- Verify underrun and overrun handling at frame boundaries.
- Compare serialized and de-serialized samples against a format-aware reference model.

## Integration Notes and Dependencies

i2s_interface usually pairs with audio FIFOs, DMA, or CSR control. It should define exactly what constitutes a sample beat on the host side so software or downstream logic does not guess.

## Edge Cases, Failure Modes, and Design Risks

- Frame alignment and sample-justification mismatches are common integration bugs.
- Clock mastership ambiguity can break board-level bring-up.
- Underrun and overrun semantics need to be explicit or audio glitches become hard to root-cause.

## Related Modules In This Domain

- spdif_interface
- tdm_audio_port
- pdm_interface
- dma_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the I2s Interface module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
