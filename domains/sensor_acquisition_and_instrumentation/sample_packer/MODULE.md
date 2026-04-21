# Sample Packer

## Overview

The sample packer reformats individual samples or narrow channel words into wider storage, transport, or DMA-friendly packets. It is the bridge between sample-rate logic and memory-oriented data movement.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

Acquisition hardware often produces samples one at a time or in narrow channel groups, while memory systems and transport links prefer wider aligned words. Ad hoc packing logic can scramble channel ordering, end-of-frame handling, or byte enables. This module standardizes that formatting step.

## Typical Use Cases

- Packing ADC or sensor samples into DMA words for memory storage.
- Aggregating several channels into a common packet stream.
- Preparing acquisition data for external links or file-oriented logging.

## Interfaces and Signal-Level Behavior

- Input side accepts samples with channel tags, frame markers, or validity qualifiers.
- Output side emits wider packed words, byte enables, and end-of-packet or end-of-frame information.
- Control side configures packing width, channel order, and handling of partial final words.

## Parameters and Configuration Knobs

- Input and output widths, channel count, packing order, and endianness.
- Frame-boundary policy, byte-enable generation, and buffer depth.
- Support for timestamps or sideband metadata inclusion in the packed stream.

## Internal Architecture and Dataflow

The module buffers incoming narrow samples until a full output word or packet fragment is assembled, then emits the packed result with the correct byte and frame metadata. It may also insert padding or terminate packets early when a frame ends. The key contract point is how the final partial word of a frame is represented and which sample appears in each byte lane.

## Clocking, Reset, and Timing Assumptions

Upstream sample ordering and channel labeling must already be correct, because the packer does not infer semantics. Reset should clear any partial word assembly so new frames start on a clean packing boundary.

## Latency, Throughput, and Resource Considerations

Packing logic is moderate in cost and often sustains one sample per cycle on the input side with bursty output behavior. Resource use is mostly buffering and muxing rather than arithmetic.

## Verification Strategy

- Check packed output ordering and byte-enable behavior against a reference for several channel and frame patterns.
- Verify partial final-word handling and reset during a partially assembled packet.
- Confirm metadata such as timestamps or frame markers stay aligned with the correct packed payload.

## Integration Notes and Dependencies

This block commonly sits just before DMA, storage, or streaming links, so its output contract should be documented with those consumers. Integrators should also state clearly whether packing order is channel-major, sample-major, or another scheme.

## Edge Cases, Failure Modes, and Design Risks

- A lane-order or byte-order mistake can make archived data unusable without obvious runtime failure.
- If partial-word policy is unclear, readers may misinterpret trailing samples.
- Frame and metadata misalignment here will contaminate every downstream consumer.

## Related Modules In This Domain

- adc_capture_interface
- storage_dma_engine
- timestamp_aligner

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Sample Packer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
