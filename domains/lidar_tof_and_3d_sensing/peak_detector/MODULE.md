# Peak Detector

## Overview

Peak Detector searches histogram or profile data for meaningful return peaks and emits their location, strength, width, and quality metrics. It bridges low-level timing accumulation and higher-level range or point-cloud generation.

## Domain Context

Peak detection is the decision layer that turns a raw timing histogram or filtered return profile into one or more candidate surfaces. In LiDAR and ToF systems it is where background counts, multipath, and real object returns are separated into a depth hypothesis the rest of the pipeline can understand.

## Problem Solved

Histograms usually contain noise, ambient background, tail energy, and occasionally several real surfaces. Without a dedicated peak detector, every consumer would invent its own criteria for what counts as a valid return, leading to inconsistent range outputs and poor multireturn behavior.

## Typical Use Cases

- Selecting the dominant depth return from a photon timing histogram.
- Emitting several candidate returns for foliage, semi-transparent surfaces, or multi-path scenes.
- Measuring peak width and confidence for later reflectivity or quality scoring.
- Finding calibration reference peaks during factory or field tuning.

## Interfaces and Signal-Level Behavior

- Inputs are histograms or processed return profiles with frame markers and optional channel identifiers.
- Outputs include one or more peak positions, amplitudes, widths, confidence scores, and frame validity flags.
- Control registers set thresholding policy, background subtraction mode, minimum peak separation, and multireturn limits.
- Diagnostic outputs may expose baseline estimate, rejected candidate peaks, and neighborhood data around the chosen maxima.

## Parameters and Configuration Knobs

- Maximum number of peaks reported per frame or channel.
- Minimum prominence, width, and separation thresholds.
- Sub-bin interpolation precision for refined peak location.
- Options for centroid-based, maximum-bin, or template-based peak extraction.

## Internal Architecture and Dataflow

A typical detector includes baseline estimation, local-max search, candidate qualification, optional interpolation, and result ranking. The module contract should make clear whether the returned position is the max bin, a centroid, or an interpolated estimate, because downstream calibration and range conversion depend on that definition.

## Clocking, Reset, and Timing Assumptions

Input histograms are assumed complete for the current frame and aligned to a known bin-to-distance mapping. Reset clears candidate history and any adaptive background estimate. If multiple surfaces are possible, the module should define whether it favors earliest arrival, strongest peak, or a ranked multipeak list.

## Latency, Throughput, and Resource Considerations

Arithmetic cost is moderate and scales with histogram length and the number of candidate peaks retained. Latency is usually one histogram frame plus the scan over its bins. Resource use is small compared with histogram storage, but comparator fanout can matter for long profiles and many channels.

## Verification Strategy

- Use synthetic single- and multi-peak histograms to verify ranking, separation, and interpolation behavior.
- Stress high-background and low-SNR cases to ensure confidence falls appropriately.
- Check that earliest-versus-strongest selection policy matches the documented mode.
- Compare peak position and amplitude against a software reference over representative histogram families.

## Integration Notes and Dependencies

Peak Detector usually feeds Range Calibration Engine, Multi Return Resolver, and Reflectivity Estimator. It should preserve enough sideband context that later stages know the frame ID, channel, and quality of each selected return.

## Edge Cases, Failure Modes, and Design Risks

- Choosing the wrong return in a multipeak scene can place geometry behind or in front of the true surface.
- A hidden change in interpolation policy can shift all ranges even when raw histograms look the same.
- Overly aggressive thresholding may erase weak but valid distant returns.

## Related Modules In This Domain

- tof_histogrammer
- multi_return_resolver
- range_calibration_engine
- reflectivity_estimator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Peak Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
