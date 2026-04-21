# Clutter Suppressor

## Overview

The clutter suppressor attenuates stationary or slowly varying background returns so moving or anomalous targets stand out more clearly in later detection stages. It is a conditioning stage for radar scenes dominated by ground or environmental clutter.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Strong static clutter can dominate radar maps and hide smaller targets, especially near zero Doppler. This module provides a reusable suppression stage so downstream detectors and trackers receive a cleaner dynamic scene representation.

## Typical Use Cases

- Reducing static background energy before CFAR or tracking.
- Improving target visibility in ground or environmental clutter.
- Providing reusable clutter mitigation in radar prototypes and products.

## Interfaces and Signal-Level Behavior

- Input side accepts coherent or magnitude-domain map data with documented axis ordering.
- Output side emits clutter-suppressed data plus optional residual-background or suppression metrics.
- Control side configures suppression mode, adaptation rate, and exclusion rules.

## Parameters and Configuration Knobs

- Input precision, adaptation depth, map dimensions or axis semantics, and suppression mode.
- Stationary-background model length, high-pass strength, and output scaling.
- Runtime parameter updates and reset or retraining policy.

## Internal Architecture and Dataflow

The suppressor models or estimates the slowly varying clutter component in the selected domain and subtracts or attenuates it before forwarding the residual scene. Implementations may be as simple as temporal averaging or more structured adaptive filters. The contract should define what background timescale is assumed and whether phase is preserved or only magnitudes are processed.

## Clocking, Reset, and Timing Assumptions

Clutter suppression only makes sense if the radar platform and scene match the documented stationarity assumptions. Reset should clear learned clutter state so a fresh environment can be acquired cleanly.

## Latency, Throughput, and Resource Considerations

This stage is moderate in cost and often stateful across many chirps or frames, with memory use driven by the clutter model. Throughput is tied to the map or chirp cadence.

## Verification Strategy

- Compare residual outputs against a reference suppression model on scenes with known static and moving components.
- Check retraining, reset, and parameter-update behavior.
- Verify whether phase-preserving and magnitude-only modes behave as documented.

## Integration Notes and Dependencies

This block usually sits between map formation and detection, and its output scale and validity should be documented with the CFAR or tracking stages that follow. Integrators should also note whether platform ego-motion is compensated elsewhere.

## Edge Cases, Failure Modes, and Design Risks

- A suppressor tuned for static platforms may erase slowly moving targets or fail under ego-motion.
- If the block destroys phase unexpectedly, later coherent processing will malfunction.
- Reset and retraining policy that is not explicit can create long transient periods with poor detection quality.

## Related Modules In This Domain

- mti_filter
- cfar_detector
- range_doppler_builder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Clutter Suppressor module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
