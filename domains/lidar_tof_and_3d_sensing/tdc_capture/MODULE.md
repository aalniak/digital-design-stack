# TDC Capture

## Overview

TDC Capture receives timing events from the ranging front end and records precise arrival measurements relative to a known start reference. It creates the low-level digital time-of-flight observables that later modules turn into range estimates and point-cloud data.

## Domain Context

TDC capture is the timing-measurement heart of many direct ToF sensors. It converts the analog reality of return-photon arrival or receiver threshold crossing into digital timing intervals referenced to the emitted laser shot, enabling later histogramming, peak selection, and range estimation.

## Problem Solved

Optical returns can occur with sub-clock precision, multiple hits, and large dynamic range. A generic counter path is usually not enough. A dedicated TDC capture block is needed to preserve fine timing, identify valid events, and move them into the digital processing domain with controlled overflow and status semantics.

## Typical Use Cases

- Capturing first-photon arrival time for direct ToF ranging.
- Recording multiple return events in systems that support several hits per shot.
- Measuring calibration pulses and reference delays inside the sensor.
- Exporting raw timing events for histogram-based depth reconstruction.

## Interfaces and Signal-Level Behavior

- Inputs include start-of-shot reference, stop events from SPAD or comparator outputs, and optional validity or channel tags.
- Outputs may be raw timestamp codes, fine/coarse time fields, hit-valid strobes, overflow flags, and shot association identifiers.
- Control paths configure active channels, capture window length, hit count limits, and dead-time handling.
- Status often reports missed hits, metastability guards, and whether the capture path is armed for the current shot.

## Parameters and Configuration Knobs

- Fine time resolution and coarse counter width.
- Maximum number of hits stored per shot or per channel.
- Capture window bounds and timeout policy.
- Number of parallel channels or pixels served by the capture instance.

## Internal Architecture and Dataflow

The block generally combines a start reference distributor, fine/coarse timing capture elements, hit qualification, and buffering into a synchronous digital interface. In systems that support multihit capture, per-shot bookkeeping and deterministic hit ordering are essential so later histogramming does not confuse overlapping returns.

## Clocking, Reset, and Timing Assumptions

TDC logic may involve a specialized timing domain or mixed-signal interface that is not identical to the main system clock. The design assumes safe CDC into the processing domain and a clean definition of what constitutes the start epoch for each shot. Reset clears partial captures and invalidates any hits not tied to a complete shot context.

## Latency, Throughput, and Resource Considerations

This module is constrained by timing precision more than arithmetic throughput. Resource usage rises with channel count and multihit buffering. Latency to downstream logic should be bounded but need not be minimal so long as shot identity and hit ordering are preserved exactly.

## Verification Strategy

- Inject synthetic start and stop timings to verify fine/coarse code composition and range.
- Stress multi-hit cases, missed-stop cases, and capture-window overruns.
- Check shot association and hit ordering when returns occur near window boundaries.
- Validate CDC and buffering behavior so no metastable or duplicated hit records escape.

## Integration Notes and Dependencies

TDC Capture feeds ToF Histogrammer, Peak Detector, and calibration logic while consuming launch timing from Laser Trigger Controller or Timestamp Synchronizer. It also depends on front-end electrical assumptions such as comparator pulse width and channel dead time that must be documented alongside the digital contract.

## Edge Cases, Failure Modes, and Design Risks

- Misdefining the start epoch introduces a systematic depth bias everywhere downstream.
- Hit reordering or dropped multihit events can distort surfaces behind semi-transparent or reflective objects.
- An overly optimistic CDC boundary can create rare but catastrophic timestamp corruption.

## Related Modules In This Domain

- laser_trigger_controller
- tof_histogrammer
- peak_detector
- range_calibration_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the TDC Capture module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
