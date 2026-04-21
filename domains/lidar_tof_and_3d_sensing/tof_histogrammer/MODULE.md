# ToF Histogrammer

## Overview

ToF Histogrammer bins TDC events over repeated shots into per-pixel or per-channel timing histograms. It converts a stream of raw hit times into a depth-ready statistical representation that is robust to low signal levels and photon noise.

## Domain Context

Histogram-based ToF sensors accumulate many timing events over repeated laser shots to estimate depth in low-photon regimes. The histogrammer is the domain block that turns sparse, noisy photon arrivals into a structured time-distribution from which the true return peak can be inferred.

## Problem Solved

Single-shot timing is often too noisy or too sparse for reliable depth estimation, especially with SPAD-based sensors. A dedicated histogrammer is needed to accumulate many returns consistently, track the acquisition window, and support later peak extraction without host-side bandwidth exploding.

## Typical Use Cases

- Accumulating photon arrival histograms for direct ToF imagers.
- Building per-shot or per-frame timing distributions before depth peak selection.
- Supporting background subtraction and ambient-light estimation in histogram space.
- Capturing calibration histograms from internal reference paths.

## Interfaces and Signal-Level Behavior

- Inputs are hit timestamps and shot identifiers from TDC Capture, optionally with pixel or channel indices.
- Outputs may expose complete histograms, partial bins, frame-done markers, and histogram-valid metadata.
- Control registers configure bin width, accumulation depth, frame length, and optional ambient or dark-count subtraction.
- Status outputs often include histogram_overflow, frame_active, dropped_hit_count, and buffer_ready indications.

## Parameters and Configuration Knobs

- Number of bins and bin-width encoding relative to TDC resolution.
- Accumulation shot count per frame and histogram memory depth.
- Supported channel or pixel fanout and whether histograms are interleaved in memory.
- Optional support for running background estimates or dual histogram banks.

## Internal Architecture and Dataflow

The histogrammer typically contains event-to-bin mapping logic, banked counters or SRAM-backed accumulators, frame control, and an output readout path. Its contract must define exactly when a histogram frame opens and closes, because depth interpretation depends on consistent shot counts and acquisition windows.

## Clocking, Reset, and Timing Assumptions

This block assumes incoming hits are correctly associated with shots and that the chosen bin width matches the intended range resolution. Reset should clear accumulation state or mark it invalid; partial histograms should never masquerade as complete measurement frames.

## Latency, Throughput, and Resource Considerations

Memory usage dominates cost, especially when many channels or fine bins are required. Throughput must support the peak hit rate under strong returns and ambient light. Latency is frame-oriented rather than hit-oriented, since useful outputs generally emerge only after a configured accumulation interval.

## Verification Strategy

- Feed synthetic hit distributions and confirm resulting histograms match the expected bin counts exactly.
- Exercise overflow, ambient-heavy scenes, and partial-frame resets.
- Check frame boundary behavior so hits from adjacent measurement frames do not mix.
- Validate memory-bank switching or double-buffering under continuous acquisition.

## Integration Notes and Dependencies

ToF Histogrammer consumes TDC events and feeds Peak Detector, Range Calibration Engine, and sometimes host diagnostics. It interacts closely with Laser Trigger Controller timing policy because accumulation depth, bin width, and shot cadence together define the sensor update rate and range performance.

## Edge Cases, Failure Modes, and Design Risks

- Using the wrong bin scaling can bias every derived distance value.
- Histogram overflow under bright scenes may silently flatten peaks unless surfaced clearly.
- Mixing hits from adjacent frames makes later peak extraction appear noisy in ways that are hard to trace back.

## Related Modules In This Domain

- tdc_capture
- peak_detector
- range_calibration_engine
- walk_error_corrector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the ToF Histogrammer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
