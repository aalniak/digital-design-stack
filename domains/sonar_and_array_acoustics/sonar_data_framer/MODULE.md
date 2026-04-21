# Sonar Data Framer

## Overview

Sonar Data Framer formats sonar measurements, detections, beams, or spectra into structured records suitable for storage, transport, or host-side parsing. It is the contract boundary between real-time processing and system-level consumption.

## Domain Context

The sonar data framer is the packaging layer that turns internal acoustic processing products into transportable records. In a real sonar stack, many downstream consumers are not raw DSP blocks but loggers, telemetry links, host processors, or operator consoles that need consistent packet structure, metadata, and timing tags.

## Problem Solved

Without a dedicated framing layer, every producer invents its own packet shape, metadata order, and timestamp convention. That makes recorder integration brittle, complicates offline analysis, and increases the chance that important contextual fields such as ping ID or beam index are lost.

## Typical Use Cases

- Packaging beamformed data for host-side visualization or logging.
- Framing matched-filter detections with ping metadata and range-cell context.
- Streaming passive spectrogram summaries over a bandwidth-limited backhaul.
- Recording calibration, fault, and status annotations alongside sonar measurement payloads.

## Interfaces and Signal-Level Behavior

- Inputs may be sample blocks, detection events, beam vectors, or spectral frames accompanied by validity and metadata fields.
- Outputs are framed packets or records with start-of-record markers, payload length, type IDs, and integrity checks.
- Control interfaces define enabled record types, metadata inclusion policy, packet size limits, and endian or packing conventions.
- Status outputs often include packet_dropped, fifo_level, framing_error, and sequence_counter indications.

## Parameters and Configuration Knobs

- Supported payload classes such as raw samples, detections, spectra, or health messages.
- Maximum payload length, metadata field widths, and optional CRC or checksum support.
- Queue depth and packetization policy for fixed-length versus event-driven records.
- Whether timestamps, platform pose tags, or ping IDs are mandatory in each frame type.

## Internal Architecture and Dataflow

The framer typically contains a metadata assembler, payload serializer, length calculator, integrity generator, and output FIFO. The key domain-specific obligation is to preserve sonar context such as beam ID, ping sequence, range indexing, and sample timing so offline analysis can reconstruct what the processing chain believed at the moment of measurement.

## Clocking, Reset, and Timing Assumptions

The module assumes upstream producers provide coherent metadata on the same cadence as payload data. Reset should clear partial packets and sequence counters in a documented way so consumers can detect discontinuities after restart.

## Latency, Throughput, and Resource Considerations

Resource use is dominated by FIFOs and serializer width conversion rather than heavy arithmetic. Latency is usually modest, but backpressure handling is critical if framed data shares egress bandwidth with other subsystems. Sustained throughput must cover the worst-case mix of record types expected during busy acoustic scenes.

## Verification Strategy

- Validate each record type against a packet reference or parser to ensure field order and lengths are correct.
- Stress variable-size payloads, backpressure, and output stalls to confirm no partial or mislabeled packets escape.
- Check sequence counters and timestamps across reset and overflow conditions.
- Replay recorded upstream metadata patterns to verify no important context fields are silently dropped.

## Integration Notes and Dependencies

Sonar Data Framer is often the last hardware stage before DMA, Ethernet, storage, or embedded CPU ingestion. It should integrate with system-wide telemetry conventions and with debugging tools that can decode the same framed products during lab bring-up and field operations.

## Edge Cases, Failure Modes, and Design Risks

- Dropping or mispacking beam and ping metadata can make recorded data scientifically useless even if payload bytes arrive intact.
- A framing overflow policy that silently discards the newest or oldest records may bias later analysis if not clearly documented.
- Checksum coverage gaps can let corrupted acoustic records appear valid to host-side software.

## Related Modules In This Domain

- ping_generator
- passive_spectrogram
- matched_filter
- target_tracker

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Sonar Data Framer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
