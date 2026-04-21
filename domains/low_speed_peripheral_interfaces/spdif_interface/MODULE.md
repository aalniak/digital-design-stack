# Spdif Interface

## Overview

spdif_interface transmits or receives S/PDIF digital audio frames, including bi-phase coding or decoding, framing interpretation, and host-facing sample transport. It is the consumer-digital-audio serial boundary block in the low-speed peripheral layer.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

S/PDIF combines audio sample transport with encoding, framing, and status-channel behavior that is cumbersome to recreate ad hoc. spdif_interface packages those tasks behind one reusable contract.

## Typical Use Cases

- Send digital audio to an external consumer audio interface.
- Receive S/PDIF audio into a local processing chain.
- Bridge software or DMA-managed audio buffers to a standard digital audio link.

## Interfaces and Signal-Level Behavior

- External signals are usually a transmit output or receive input plus any required recovered-clock or framing support exposed by the implementation.
- Host or downstream-facing interfaces move audio samples and status or channel information.
- Status commonly reports lock, frame alignment, parity or coding errors, underrun, and overrun.

## Parameters and Configuration Knobs

- DIRECTION_MODE selects TX, RX, or dual support.
- SAMPLE_WIDTH defines supported sample size.
- STATUS_CHANNEL_EN exposes channel-status information if implemented.
- FIFO_DEPTH sizes sample buffering.
- RECOVERY_MODE defines how receive-side clock or framing lock is handled.

## Internal Architecture and Dataflow

An S/PDIF interface typically includes sample framing, bi-phase mark coding or decoding, and buffering between serial timing and local sample timing. The main contract questions are which metadata fields are surfaced and how receive lock or transmitter underrun is reported.

## Clocking, Reset, and Timing Assumptions

The module should define whether local logic sees already unpacked audio samples, raw subframes, or some intermediate format. Reset should clear framing state and any pending partial subframe. Receive-side lock acquisition policy must be explicit.

## Latency, Throughput, and Resource Considerations

External link rates are modest, so correctness of framing and buffer management dominates over internal timing. FIFO sizing matters because underrun or overrun directly affects user-visible audio quality.

## Verification Strategy

- Exercise TX and RX paths with valid framed audio data.
- Verify parity or coding error detection if supported.
- Check lock acquisition and loss behavior on RX.
- Stress underrun and overrun conditions around frame boundaries.

## Integration Notes and Dependencies

spdif_interface commonly pairs with audio FIFOs, DMA, or CSR control and may coexist with I2S or PDM interfaces in the same audio subsystem. It should define clearly what sample format the rest of the system sees.

## Edge Cases, Failure Modes, and Design Risks

- Framing and sample unpack assumptions can mismatch downstream audio logic.
- RX lock behavior can be under-specified and cause unstable startup.
- Underrun and overrun semantics matter because glitches become immediately audible.

## Related Modules In This Domain

- i2s_interface
- pdm_interface
- audio_fifo
- dma_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Spdif Interface module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
