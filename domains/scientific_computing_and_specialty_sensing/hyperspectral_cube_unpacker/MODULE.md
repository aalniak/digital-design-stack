# Hyperspectral Cube Unpacker

## Overview

Hyperspectral Cube Unpacker parses and reorders packed hyperspectral data into explicit spatial-spectral cube structure or analysis-friendly band streams. It provides the ingest and normalization stage for hyperspectral sensing pipelines.

## Domain Context

Hyperspectral systems often store or transmit data as packed cubes whose axes represent spatial coordinates and wavelength bands. In this scientific domain an unpacker exists to restore the cube into a usable memory and stream layout for calibration, analysis, or reconstruction pipelines.

## Problem Solved

Raw hyperspectral outputs may be band-interleaved, packetized, compressed, or otherwise laid out for transport rather than analysis. A dedicated unpacker makes band order, frame structure, and pixel indexing explicit so later calibration and classification stages see a stable cube contract.

## Typical Use Cases

- Ingesting packed hyperspectral camera output into analysis pipelines.
- Separating spatial and spectral axes for calibration or reconstruction.
- Supporting band-wise processing and storage in scientific imaging systems.
- Normalizing transport-oriented hyperspectral formats into one internal cube layout.

## Interfaces and Signal-Level Behavior

- Inputs are packed hyperspectral records or pixel-band streams plus frame and line metadata.
- Outputs provide cube-formatted data, band-major or pixel-major streams, and frame-complete status.
- Control interfaces configure input packing profile, band count, line size, and output ordering.
- Status signals may expose format_invalid, frame_truncated, and band_index_error conditions.

## Parameters and Configuration Knobs

- Band count and spatial dimension limits.
- Input and output sample precision.
- Supported input packing profiles and output layout options.
- Optional stride or subcube extraction support.

## Internal Architecture and Dataflow

The unpacker usually combines packet or line parsing, address remapping, and output buffering to restore the intended cube organization. The key contract is the precise mapping between input order and output cube coordinates, because spectral calibration and downstream analytics depend on band identity being exact.

## Clocking, Reset, and Timing Assumptions

The module assumes input metadata correctly identifies frame, line, and band structure. Reset clears partial cube state. If only a subset of bands or a cropped region is emitted, the output coordinate and metadata conventions should be explicit.

## Latency, Throughput, and Resource Considerations

Resource use is dominated by buffering and address-generation logic rather than arithmetic. Throughput must match sensor or storage ingest rate. The practical tradeoff is between flexible format support and the memory needed for large cubes or rich reordering modes.

## Verification Strategy

- Compare unpacked output against a software reference for each supported input format.
- Stress truncated frames, band-count mismatches, and cropped-output modes.
- Verify coordinate labeling and band ordering explicitly.
- Run end-to-end tests with spectral calibration or analysis software to confirm interoperability.

## Integration Notes and Dependencies

Hyperspectral Cube Unpacker commonly feeds Spectral Calibration Engine, Compressive Sensing Block, or host-side scientific analysis. It should align closely with sensor documentation and calibration tooling because a band-order mistake ruins every later stage.

## Edge Cases, Failure Modes, and Design Risks

- Band-order confusion can invalidate scientific conclusions while the cube still looks structurally plausible.
- Partial-frame handling that is not explicit can leave stale data in later analyses.
- Supporting many layout modes without crisp metadata increases integration fragility.

## Related Modules In This Domain

- spectral_calibration_engine
- compressive_sensing_block
- high_speed_histogrammer
- interferometry_helper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Hyperspectral Cube Unpacker module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
