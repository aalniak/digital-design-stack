# Range-Doppler Builder

## Overview

The range-Doppler builder assembles range and Doppler processing outputs into a coherent two-dimensional map with explicit bin indexing and metadata. It is the structural stage that turns separate transforms into a usable detection surface.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Range and Doppler FFT outputs are useful only if their axes, ordering, and validity are combined consistently into a map representation. This module provides that assembly step so detectors and trackers can consume a stable range-Doppler product.

## Typical Use Cases

- Constructing range-Doppler maps for CFAR and display.
- Combining transform outputs into a coherent map product for later perception stages.
- Providing reusable 2D radar-map formation across waveform profiles.

## Interfaces and Signal-Level Behavior

- Input side accepts range-bin and Doppler-bin data, often in a streaming or tiled order.
- Output side emits map cells, map rows, or stored map memory with explicit range and Doppler indexing.
- Control side configures axis ordering, map dimensions, and output formatting or buffering mode.

## Parameters and Configuration Knobs

- Range-bin count, Doppler-bin count, cell precision, and storage or streaming mode.
- Zero-Doppler centering policy, axis ordering, and output metadata width.
- Runtime profile selection and map-boundary signaling.

## Internal Architecture and Dataflow

The builder consumes transform outputs in the order produced by earlier stages and packs them into a consistent range-Doppler grid, adding axis metadata or storing the map in memory if required. The contract should state clearly whether the map is range-major, Doppler-major, centered, or raw-order, because downstream CFAR and displays depend on that convention.

## Clocking, Reset, and Timing Assumptions

The block assumes the upstream transforms have already produced valid bin outputs according to the documented ordering. Reset should clear partial map state and restart at a map origin.

## Latency, Throughput, and Resource Considerations

Map building is more about data organization and buffering than arithmetic, but it must match transform throughput without losing cell ordering. Resource use depends on whether the map is streamed or fully buffered.

## Verification Strategy

- Compare emitted map ordering against a reference range-Doppler layout for representative dimensions.
- Check axis metadata, zero-Doppler centering, and map-boundary signals.
- Verify reset and incomplete-map handling.

## Integration Notes and Dependencies

This block typically sits directly before CFAR or display logic, so its axis ordering should be documented with those consumers. Integrators should also note whether magnitudes, powers, or complex bins are carried into the map representation.

## Edge Cases, Failure Modes, and Design Risks

- A range-major versus Doppler-major mismatch can make every downstream visualization and detector disagree.
- Centered-versus-raw Doppler ordering often creates subtle sign inversions downstream.
- If map boundaries are ambiguous, detectors may mix adjacent frames or bursts.

## Related Modules In This Domain

- range_fft
- doppler_fft
- cfar_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Range-Doppler Builder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
