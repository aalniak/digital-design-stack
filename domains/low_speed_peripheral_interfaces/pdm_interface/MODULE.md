# Pdm Interface

## Overview

pdm_interface handles pulse-density modulated digital audio or sensor bitstreams, including clocking, capture or drive, and host-facing buffering or framing. It is the serial boundary block for very simple oversampled one-bit data paths.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

PDM streams look simple because they are one bit wide, but practical use still requires clock ownership, channel framing in stereo cases, and a clear handoff to downstream decimation or buffering logic. pdm_interface centralizes that contract.

## Typical Use Cases

- Capture microphone data from a PDM source.
- Drive a simple one-bit oversampled audio or sensor sink.
- Provide a clean digital boundary between PDM pins and downstream decimation logic.

## Interfaces and Signal-Level Behavior

- Bus-facing signals usually include a clock and one or more PDM data lines.
- Host or downstream-facing outputs may present captured bit groups, sample windows, or FIFO-style data.
- Status often reports activity, overrun, and clock mode.

## Parameters and Configuration Knobs

- NUM_LANES sets supported PDM channels.
- CLOCK_MASTER_EN defines whether the interface generates the PDM clock.
- PACKING_MODE selects how one-bit data is grouped for downstream logic.
- FIFO_DEPTH sizes temporary buffering.
- EDGE_SELECT chooses the capture edge relative to the PDM clock.

## Internal Architecture and Dataflow

The interface generally contains a clocking element, bit capture or drive logic, and optional packing into wider words for downstream logic. The reusable contract should clarify whether the block stops at raw bit capture or also imposes channel framing assumptions.

## Clocking, Reset, and Timing Assumptions

PDM alone does not produce meaningful samples without downstream decimation, so the module should document that boundary clearly. Reset should clear partial packed state and define clock startup behavior.

## Latency, Throughput, and Resource Considerations

External bit rates are moderate, but internal packing and buffering should comfortably absorb host or downstream burstiness. Cost is usually low unless many lanes or deep FIFOs are supported.

## Verification Strategy

- Check capture or drive timing on the selected edge.
- Verify lane ordering and packing behavior.
- Exercise overrun or underflow policy if buffering exists.
- Confirm clock generation or consumption mode matches the configured role.

## Integration Notes and Dependencies

pdm_interface usually feeds a decimator or audio front end and may share control with I2S or audio CSR logic. It should make explicit whether it is only a pin-level interface or also a framing helper.

## Edge Cases, Failure Modes, and Design Risks

- Confusing raw PDM transport with actual audio sample generation can lead to wrong system assumptions.
- Clock-edge and lane-order mismatches are common board-level bugs.
- If packing semantics are vague, downstream decimation logic may interpret bits incorrectly.

## Related Modules In This Domain

- i2s_interface
- spdif_interface
- pdm_decimator
- dma_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pdm Interface module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
