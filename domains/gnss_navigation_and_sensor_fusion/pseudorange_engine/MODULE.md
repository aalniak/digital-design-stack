# Pseudorange Engine

## Overview

Pseudorange Engine converts tracked code-phase and timing information into timestamped pseudorange measurements with associated quality metadata. It packages the code-domain observables needed for position, velocity, and timing solutions.

## Domain Context

The pseudorange engine extracts one of the core GNSS observables: the apparent signal travel time from satellite to receiver, expressed as range with receiver-clock bias still embedded. It is the measurement layer that links channel tracking to navigation solving.

## Problem Solved

Pseudorange is not just code phase copied into a register. It requires careful handling of code epochs, receiver time, satellite timing references, and measurement validity. A dedicated engine keeps that translation explicit and consistent across channels.

## Typical Use Cases

- Producing per-satellite pseudorange measurements for a position fix.
- Generating measurement sets for sensor-fusion filters or timing solutions.
- Supporting quality screening based on lock status, geometry, or channel health.
- Exporting raw measurements for offline receiver analysis and validation.

## Interfaces and Signal-Level Behavior

- Inputs include code-phase state from the DLL, channel timing markers, and decoded navigation timing context.
- Outputs provide pseudorange value, measurement epoch, satellite identifier, and quality flags or uncertainty hints.
- Control registers define measurement cadence, smoothing policy, and validity thresholds.
- Diagnostic outputs may expose raw code phase, code epoch counters, and measurement rejection reasons.

## Parameters and Configuration Knobs

- Code-phase resolution and output range precision.
- Measurement cadence and optional smoothing depth.
- Quality gating thresholds based on lock indicators or discriminator noise.
- Support for multiple constellations or signal-specific timing conventions.

## Internal Architecture and Dataflow

The block typically combines channel timing capture, code-epoch accounting, receiver-time alignment, and formatting of the resulting observable. The contract should state the exact measurement epoch convention and whether smoothing or carrier aiding has already been applied, because solver behavior depends on that knowledge.

## Clocking, Reset, and Timing Assumptions

Pseudorange extraction assumes the tracking loops are sufficiently locked and that message-derived timing context is current. Reset clears measurement continuity. If measurements are output only at common epochs, channel alignment policy should be documented clearly.

## Latency, Throughput, and Resource Considerations

Arithmetic cost is moderate but predictable. Latency should be deterministic so measurements across satellites correspond to the documented epoch. Resource use rises with the number of simultaneously tracked channels and any smoothing state retained.

## Verification Strategy

- Generate synthetic code-phase trajectories and verify resulting pseudorange values against a reference receiver model.
- Check epoch alignment across multiple channels at the measurement boundary.
- Stress invalid-lock and stale-message cases to ensure measurements are gated correctly.
- Verify smoothing or carrier-aided modes are reflected accurately in metadata or documentation.

## Integration Notes and Dependencies

Pseudorange Engine consumes Code Tracking DLL state and decoded navigation timing, then feeds Kalman Fusion Engine or an external navigation solver. It should also integrate with PPS alignment and disciplined clock logic when the design supports precise timing outputs.

## Edge Cases, Failure Modes, and Design Risks

- A subtle measurement-epoch mismatch across channels can bias fixes without obvious per-channel faults.
- If smoothing is applied but not declared, downstream filters may double-count information.
- Using stale navigation timing context can produce coherent but wrong ranges.

## Related Modules In This Domain

- code_tracking_dll
- nav_bit_synchronizer
- carrier_phase_engine
- kalman_fusion_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pseudorange Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
