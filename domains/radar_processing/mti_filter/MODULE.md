# MTI Filter

## Overview

The MTI filter suppresses static or slowly varying returns by high-pass filtering across pulses or chirps, emphasizing moving targets. It is a classic clutter-reduction block in pulse-Doppler and FMCW radar systems.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Stationary clutter often dominates radar returns and hides moving objects. A moving-target-indication filter addresses that, but its cancellation order, blind-speed behavior, and framing must be explicit. This module provides that temporal high-pass stage.

## Typical Use Cases

- Removing zero-velocity clutter before Doppler processing or detection.
- Providing a classic MTI stage in pulse-Doppler style processing.
- Supporting reusable temporal clutter suppression in radar chains.

## Interfaces and Signal-Level Behavior

- Input side accepts coherent returns organized by pulse or chirp index.
- Output side emits clutter-suppressed returns with preserved coherent timing.
- Control side configures filter order, coefficients, and startup or reset policy.

## Parameters and Configuration Knobs

- Sample precision, pulse-history depth, filter mode, and output scaling.
- Blind-speed tradeoff profile, coefficient precision, and runtime mode selection.
- Reset or retraining policy and optional bypass mode.

## Internal Architecture and Dataflow

The filter compares current and previous slow-time samples using a configured high-pass structure to cancel stationary components while retaining moving-target energy. Depending on the design it may be a simple difference filter or a richer temporal cancellation chain. The contract should state clearly whether phase is preserved and how many pulses are consumed before the output is valid.

## Clocking, Reset, and Timing Assumptions

The input must be coherently ordered in slow time and aligned to the documented pulse cadence. Reset should clear temporal history and define startup output behavior explicitly.

## Latency, Throughput, and Resource Considerations

MTI filtering is modest in arithmetic cost but stateful over pulses. Resource use depends on filter order and the amount of pulse history carried.

## Verification Strategy

- Compare filtered output against a reference MTI response on stationary clutter and moving-target scenarios.
- Check startup, reset, and coefficient-mode behavior.
- Verify scaling and phase preservation according to the documented filter structure.

## Integration Notes and Dependencies

This block typically sits before Doppler FFT or CFAR stages, so its output scale and blind-speed implications should be documented with those consumers. Integrators should also note whether platform-motion compensation is expected upstream.

## Edge Cases, Failure Modes, and Design Risks

- An MTI filter tuned for one pulse cadence may create unexpected blind velocities at another.
- Startup transients can look like false targets if validity timing is not explicit.
- If the block is assumed phase preserving when it is not, later coherent processing will degrade.

## Related Modules In This Domain

- clutter_suppressor
- doppler_fft
- cfar_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the MTI Filter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
