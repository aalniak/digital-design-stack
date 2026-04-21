# Micro-Doppler Analyzer

## Overview

The micro-Doppler analyzer studies fine time-varying Doppler structure caused by rotating, vibrating, or otherwise articulated target motion. It is a specialized characterization stage built on coherent radar returns rather than a basic detector.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Some targets carry identifying signatures in their time-varying Doppler content, but those signatures are lost if the system only reports a coarse velocity bin. This module provides a reusable analysis stage for those finer motion patterns.

## Typical Use Cases

- Characterizing rotating or articulated targets in surveillance radar.
- Generating micro-Doppler features for classification or forensics.
- Providing reusable fine-motion analysis in coherent radar research systems.

## Interfaces and Signal-Level Behavior

- Input side accepts coherent slow-time or Doppler-resolved target data over an analysis window.
- Output side emits spectrogram-like features, summary metrics, or target-level micro-Doppler records.
- Control side configures analysis window, transform mode, and feature-selection policy.

## Parameters and Configuration Knobs

- Input precision, analysis-window length, output feature width, and transform size.
- Spectrogram versus summary-feature mode, overlap settings, and target-selection inputs.
- Runtime profile selection and frame-to-feature alignment behavior.

## Internal Architecture and Dataflow

The analyzer observes how Doppler content evolves over time for a selected target or cell, often using short-time transforms or summary metrics derived from that time-frequency behavior. The contract should define the output representation clearly, since some uses need full time-frequency maps while others need compact classification features.

## Clocking, Reset, and Timing Assumptions

The input should already be associated with a coherent target or cell of interest and retain the phase or Doppler information required for analysis. Reset should clear window state and any target-specific accumulation before a new analysis interval begins.

## Latency, Throughput, and Resource Considerations

This stage is moderate to heavy depending on window size and output richness, but it usually runs on selected targets rather than the whole scene. Resource use depends on transform size and feature buffering.

## Verification Strategy

- Compare produced features against a reference micro-Doppler analysis on synthetic rotating-target data.
- Check window alignment, overlap behavior, and target-selection semantics.
- Verify reset and re-targeting behavior between analysis intervals.

## Integration Notes and Dependencies

This block often follows target association or cell selection and may feed classifiers or human analysis tools. Integrators should document whether outputs are for machine classification, operator display, or both.

## Edge Cases, Failure Modes, and Design Risks

- If the input selection is unstable, the analyzer may appear noisy even when implemented correctly.
- Window-size changes alter feature meaning and must be documented with downstream consumers.
- Losing phase coherence upstream can quietly invalidate micro-Doppler interpretation.

## Related Modules In This Domain

- doppler_fft
- target_tracker
- stap_research_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Micro-Doppler Analyzer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
