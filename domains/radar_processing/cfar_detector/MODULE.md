# CFAR Detector

## Overview

The CFAR detector identifies statistically significant cells in range, Doppler, or angle maps by adapting detection thresholds to local background conditions. It is a common target-detection stage in radar pipelines.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Static thresholds fail in cluttered or range-varying radar scenes, but target detection still needs predictable false-alarm control. This module provides adaptive thresholding over map data so detections are more stable across changing backgrounds.

## Typical Use Cases

- Detecting targets in range-Doppler or angle-range maps.
- Providing constant-false-alarm thresholding after spectral processing.
- Serving as a reusable detection stage in radar prototypes and products.

## Interfaces and Signal-Level Behavior

- Input side accepts scalar magnitude or power maps with explicit cell ordering.
- Output side emits detection flags, threshold values, and optional noise-estimate metadata.
- Control side configures CFAR window geometry, guard cells, and detector variant.

## Parameters and Configuration Knobs

- Map dimensions, cell precision, training and guard window size, and threshold scaling.
- CA, GOCA, SOCA, or other supported CFAR variant, and output flag format.
- Runtime parameter update support and border-cell handling.

## Internal Architecture and Dataflow

The block examines training cells around a candidate cell under test, excludes nearby guard cells, estimates local background, and compares the candidate against a scaled threshold. Different CFAR families handle nonhomogeneous backgrounds differently, and the documentation should identify which are implemented and how edges are treated.

## Clocking, Reset, and Timing Assumptions

Input maps should already be in the documented magnitude or power domain with known scaling, because threshold factors depend on that interpretation. Reset should clear any line or window state before a new map begins.

## Latency, Throughput, and Resource Considerations

CFAR is moderate in arithmetic and buffering cost, often dominated by sliding-window sums or extrema. Resource use depends on map size and the chosen CFAR variant.

## Verification Strategy

- Compare detections and thresholds against a software CFAR reference across homogeneous noise and clutter edges.
- Check guard-cell, border, and variant-specific behavior.
- Verify threshold scaling and detection-flag timing over complete maps.

## Integration Notes and Dependencies

This block usually follows range-Doppler or beam-space processing and precedes tracking or clustering, so detection-map coordinate conventions should be shared with those consumers. Integrators should also document whether detections are sparse outputs or dense flags.

## Edge Cases, Failure Modes, and Design Risks

- A mismatch between power and magnitude scaling can shift false-alarm behavior dramatically.
- Border handling differences from software references are common and can affect unit-test agreement.
- CFAR windows that span target sidelobes may suppress real detections if not tuned carefully.

## Related Modules In This Domain

- range_doppler_builder
- target_tracker
- clutter_suppressor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the CFAR Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
