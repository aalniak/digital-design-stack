# Fringe Phase Unwrapper

## Overview

Fringe Phase Unwrapper converts wrapped phase measurements into continuous phase fields or sequences by resolving 2pi ambiguities according to the selected unwrapping strategy. It provides the continuity-restoration stage for phase-based sensing pipelines.

## Domain Context

Fringe phase unwrapping appears in interferometry, structured-light measurement, and other phase-based sensing systems where the measured phase is periodic but the underlying physical quantity is not. In this scientific domain it is the bridge from wrapped phase to continuous geometric or displacement interpretation.

## Problem Solved

Wrapped phase values are locally meaningful but globally ambiguous. A dedicated unwrapping block is needed so the assumptions about continuity, residue handling, and path strategy are explicit rather than buried in application logic.

## Typical Use Cases

- Unwrapping structured-light or interferometric phase maps into continuous surfaces.
- Recovering displacement or height information from periodic phase observations.
- Supporting phase-based scientific imaging pipelines in hardware experiments.
- Providing a deterministic unwrapping stage for specialty metrology systems.

## Interfaces and Signal-Level Behavior

- Inputs are wrapped phase samples or maps plus boundary, validity, and optional quality metadata.
- Outputs provide unwrapped phase values, continuity flags, and completion status for lines or frames.
- Control interfaces configure unwrap mode, neighborhood policy, and quality-guided or path-guided strategy selection.
- Status signals may expose residue_detected, unwrap_ambiguous, and frame_done conditions.

## Parameters and Configuration Knobs

- Phase precision and map dimensions.
- Line-based versus 2D field unwrapping support.
- Quality-guided or sequential unwrapping policy.
- Optional masking or invalid-pixel handling.

## Internal Architecture and Dataflow

The block often contains phase-difference evaluation, ambiguity accumulation, and optional quality-guided traversal or correction logic. The architectural contract should define whether unwrapping is purely local line-by-line, full-frame 2D, or only a helper stage for a host-side algorithm, because those modes have very different robustness and memory costs.

## Clocking, Reset, and Timing Assumptions

The module assumes neighboring samples share enough continuity that unwrapping is meaningful under the selected strategy. Reset clears phase-accumulation history. If invalid or low-quality pixels are supported, the block should state whether they break continuity, are interpolated across, or are simply flagged unresolved.

## Latency, Throughput, and Resource Considerations

Line-based unwrapping can be streaming and efficient, while richer 2D strategies are more control and memory intensive. The tradeoff is between robustness to residues or discontinuities and the hardware cost of more global reasoning.

## Verification Strategy

- Compare output against a software phase-unwrapping reference for representative synthetic and measured phase maps.
- Stress sharp discontinuities, low-quality regions, and residue-heavy inputs.
- Verify ambiguity flags and invalid-region behavior explicitly.
- Check that line and frame boundary semantics do not introduce artificial phase jumps.

## Integration Notes and Dependencies

Fringe Phase Unwrapper commonly follows Interferometry Helper or structured-light phase extraction and feeds geometry reconstruction or calibration stages. It should align with Spectral Calibration or metrology software on phase units and validity semantics.

## Edge Cases, Failure Modes, and Design Risks

- An unwrap that looks smooth can still be globally wrong if discontinuities or residues are mishandled.
- Line-by-line strategies may fail on 2D ambiguity patterns that need more global context.
- If invalid-pixel behavior is vague, downstream geometry solvers may overtrust fabricated continuity.

## Related Modules In This Domain

- interferometry_helper
- spectral_calibration_engine
- hyperspectral_cube_unpacker
- high_speed_histogrammer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Fringe Phase Unwrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
