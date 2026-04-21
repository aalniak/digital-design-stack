# Hydrophone Frontend Interface

## Overview

Hydrophone Frontend Interface receives one or more hydrophone sample streams and turns them into a clean digital array-data contract for the rest of the sonar stack. It handles framing, channel alignment, status propagation, and any lightweight preprocessing needed before beamforming or spectral analysis.

## Domain Context

The hydrophone frontend interface is the ingest boundary between underwater acoustic sensors and the digital sonar processing chain. It packages digitized hydrophone or preamplifier outputs, aligns channels, and preserves timing and gain metadata so beamforming and detection stages see a trustworthy representation of the acoustic field.

## Problem Solved

Raw hydrophone capture paths often arrive with board-specific lane ordering, converter framing, gain-state sideband signals, and occasional channel slips. If that complexity leaks into every downstream block, array calibration becomes fragile and later algorithms cannot reliably distinguish real acoustic phase differences from ingestion artifacts.

## Typical Use Cases

- Bringing multichannel hydrophone ADC data into a passive listening or active receive pipeline.
- Aligning lane-multiplexed converter outputs before beamforming and matched filtering.
- Capturing gain, overload, and health indicators from analog front-end components.
- Normalizing board-level channel ordering into a stable logical sensor index map.

## Interfaces and Signal-Level Behavior

- Upstream inputs may be parallel ADC buses, serialized converter lanes, or packetized sample frames from a front-end FPGA or mixed-signal ASIC.
- Downstream outputs usually present one sample per channel per frame with valid markers, frame boundaries, and optional timestamp tags.
- Status signals often include channel_lock, overflow, saturation, missing_channel, and front_end_fault indications.
- Control registers commonly cover channel enable masks, reorder tables, gain metadata mapping, and startup calibration delays.

## Parameters and Configuration Knobs

- Number of hydrophone channels and logical-to-physical reorder depth.
- Input and output sample widths, framing ratio, and optional sign extension behavior.
- Allowance for deskew depth, startup settling interval, and per-channel mute or substitution policy.
- Whether embedded timestamps, gain indices, or analog fault flags travel with each frame.

## Internal Architecture and Dataflow

Most implementations contain a capture block matched to the converter interface, a channel deskew stage, a reorder map, and a frame packer that emits synchronous multichannel snapshots. Optional sideband paths latch analog status bits and attach them to the same frame cadence so downstream detectors can ignore unreliable intervals or flag clipped data.

## Clocking, Reset, and Timing Assumptions

The interface usually bridges from a converter clock into the main processing clock through a well-defined elastic buffer or CDC boundary. Reset must not release downstream processing until frame alignment is established, because array algorithms are highly sensitive to channel swaps and sample skew.

## Latency, Throughput, and Resource Considerations

Throughput scales with channel count and sample rate, so resource use is dominated by deskew buffers, framing memories, and any lane-deserialization logic. Latency should remain deterministic once lock is achieved; absolute delay matters less than repeatable channel-to-channel alignment.

## Verification Strategy

- Inject known per-channel tones and confirm output lane ordering and sign handling are correct.
- Force skew, missing-frame, and temporary unlock scenarios to verify graceful fault reporting and recovery.
- Check timestamp and sideband alignment so gain or overload flags are attached to the correct sample frame.
- Run array-coherence tests confirming simultaneous impulses remain aligned at the downstream interface.

## Integration Notes and Dependencies

This module sits directly upstream of passive detectors, matched filters, spectrogram engines, and beamformers. It should integrate with board support logic that knows converter bring-up details, and with calibration storage that captures static channel delays, polarity inversions, or gain differences discovered during system characterization.

## Edge Cases, Failure Modes, and Design Risks

- A single silent channel reorder bug can invalidate every beamforming and localization result.
- If converter unlocks are not surfaced clearly, later stages may integrate corrupted data as though it were valid.
- Dropping metadata such as overload or gain-state flags can hide front-end operating problems during field tests.

## Related Modules In This Domain

- delay_and_sum_beamformer
- array_calibration
- passive_detector
- passive_spectrogram

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Hydrophone Frontend Interface module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
