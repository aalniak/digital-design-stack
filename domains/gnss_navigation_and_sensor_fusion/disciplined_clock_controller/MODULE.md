# Disciplined Clock Controller

## Overview

Disciplined Clock Controller adjusts a local clock or synthesizer control interface based on GNSS-derived timing error and stability metrics. It creates a system-usable clock discipline loop from raw timing observations.

## Domain Context

A disciplined clock controller turns GNSS timing observables into a stable local timebase for the broader system. In embedded timing and navigation hardware it manages how internal oscillators are corrected, slewed, or held over when GNSS timing is present or temporarily lost.

## Problem Solved

GNSS can provide excellent timing, but a local oscillator still needs controlled correction rather than abrupt jumps. Without a dedicated discipline controller, timekeeping may oscillate, wander in holdover, or expose unclear timing quality to the rest of the platform.

## Typical Use Cases

- Steering a local oscillator to GNSS time in a timing receiver.
- Entering holdover gracefully when GNSS timing becomes unavailable.
- Providing clock-quality and discipline-status information to the rest of the SoC.
- Filtering noisy timing observations before applying correction to hardware clock controls.

## Interfaces and Signal-Level Behavior

- Inputs include timing error estimates, PPS offset metrics, oscillator status, and optional environmental data such as temperature.
- Outputs provide frequency or phase correction commands, holdover status, and quality indicators.
- Control registers configure loop bandwidth, correction limits, and holdover strategy.
- Diagnostic outputs may expose filtered error, control effort, and oscillator health history.

## Parameters and Configuration Knobs

- Correction word width and update cadence.
- Loop filter coefficients and maximum slew limits.
- Holdover timeout, drift model selection, and quality thresholds.
- Support for phase-steer, frequency-steer, or mixed discipline modes.

## Internal Architecture and Dataflow

The controller typically contains a timing-error filter, control law, limit enforcement, and status estimator. The architectural contract should define whether it disciplines phase directly, frequency only, or both, because downstream timing behavior during lock and holdover depends on that choice.

## Clocking, Reset, and Timing Assumptions

It assumes the incoming GNSS timing measurements are referenced to a known epoch and that oscillator control interfaces behave monotonically enough for feedback control. Reset should revert the clock-control output to a documented safe state and invalidate timing-quality claims until lock is re-established.

## Latency, Throughput, and Resource Considerations

Arithmetic load is low, but stability and observability matter greatly. Update latency and loop bandwidth must be matched to oscillator behavior; overly aggressive correction can be as harmful as no correction. Resource use mainly comes from filters and status-history storage.

## Verification Strategy

- Inject timing-error trajectories and verify lock, settling, and holdover behavior.
- Check correction limiting and anti-windup behavior under large offsets.
- Stress loss and return of GNSS timing to ensure clean transition between disciplined and holdover modes.
- Compare control-loop response against a high-level timing model for representative oscillators.

## Integration Notes and Dependencies

Disciplined Clock Controller consumes PPS Aligner or measurement timing outputs and interacts with hardware clock generation blocks. It should expose enough status for system software to decide when time is trustworthy enough for synchronization, logging, or coordinated sensing.

## Edge Cases, Failure Modes, and Design Risks

- A discipline loop that looks stable in the lab may oscillate with a different oscillator or temperature range.
- If holdover quality is overstated, the system may trust time that is already drifting badly.
- Undocumented phase-step behavior can break downstream consumers that expect only smooth slew corrections.

## Related Modules In This Domain

- pps_aligner
- kalman_fusion_engine
- strapdown_integrator
- dead_reckoning_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Disciplined Clock Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
