# ADC Capture Interface

## Overview

The ADC capture interface receives digitized samples from an external or internal analog-to-digital converter and presents them to the wider fabric with clear framing, timing, and status semantics. It is the front door of many sensing systems.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

ADC links are deceptively tricky because sample clocks, lane alignment, data formatting, and validity timing must all be right before downstream DSP can trust the samples. This module centralizes that interface work so later blocks can see a stable sample stream instead of raw converter signaling.

## Typical Use Cases

- Capturing streamed samples from high-speed data converters into DSP pipelines.
- Bridging board-level converter formats into repository-standard sample interfaces.
- Providing a reusable acquisition boundary for radar, sonar, instrumentation, and imaging systems.

## Interfaces and Signal-Level Behavior

- Converter side connects to sample clocks, serial or parallel data lanes, frame markers, and optional overrange signals.
- Fabric side emits samples with valid timing, channel indexing, and optional frame or packet boundaries.
- Status side reports lock, alignment, overflow, and data-format conditions relevant to bring-up and health monitoring.

## Parameters and Configuration Knobs

- Sample width, lane count, serial versus parallel capture mode, and channel count.
- Clocking mode, deserialization ratio, and output packing format.
- Optional alignment training, test-pattern support, and overrange flag handling.

## Internal Architecture and Dataflow

The block typically performs deserialization or word assembly, lane or frame alignment, optional format conversion, and handoff into a fabric-side clock domain. In many systems it also captures converter status such as overrange or synchronization state. The main contract question is where the authoritative sample boundary comes from and when output data is considered valid after reset or relock.

## Clocking, Reset, and Timing Assumptions

The converter clocking relationship and supported data format must be known and documented because the block cannot infer them safely. Reset should clear partial words and alignment state so the first published samples belong to a cleanly aligned stream.

## Latency, Throughput, and Resource Considerations

This interface often runs at the fastest ingress rate in the system, so timing closure and clean CDC boundaries matter. Resource use depends on deserialization depth, lane count, and any buffering between converter and fabric domains.

## Verification Strategy

- Check sample alignment, word assembly, and frame timing against converter-format reference patterns.
- Verify reset and relock behavior after clock disturbances or lane errors.
- Exercise overrange and status propagation so measurement systems can diagnose front-end issues.

## Integration Notes and Dependencies

This module sits directly under sample-processing chains, so data format, channel ordering, and sample clock ownership should be written down alongside it. Integrators should also document when downstream DSP may trust output validity after startup.

## Edge Cases, Failure Modes, and Design Risks

- A lane-order or bit-order mistake can poison every downstream algorithm while still producing changing numbers.
- If sample-valid timing is ambiguous, packetizers and timestamps may drift relative to the actual waveform.
- Converter-specific alignment assumptions can break quietly when a board revision changes the device or mode.

## Related Modules In This Domain

- dac_playback_interface
- timestamp_aligner
- sample_packer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the ADC Capture Interface module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
