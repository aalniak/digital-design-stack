# Dead Time Inserter

## Overview

Dead Time Inserter transforms complementary PWM commands into gate-safe outputs by enforcing a non-overlap interval around switching transitions. It protects the power stage from shoot-through while preserving as much modulation fidelity as practical.

## Domain Context

Dead-time insertion is a safety-critical bridge between ideal PWM commands and real half-bridge gate drives. In motor control and power electronics it prevents simultaneous conduction of high-side and low-side devices, accounting for finite switching delay and device tail current.

## Problem Solved

Real switching devices do not turn on and off instantaneously. If complementary commands are applied without dead time, cross-conduction can destroy MOSFETs or IGBTs quickly. A dedicated inserter centralizes this safety function and makes its timing explicit.

## Typical Use Cases

- Generating safe complementary gate-drive signals for inverter legs.
- Adapting dead time across device technologies or gate-driver delays.
- Coordinating fault shutdown behavior with PWM disable paths.
- Supporting digital compensation workflows that account for dead-time distortion.

## Interfaces and Signal-Level Behavior

- Inputs are complementary or single-ended PWM commands plus enable and fault controls.
- Outputs provide gate-ready high-side and low-side signals with enforced non-overlap.
- Control registers set dead-time duration, polarity, and optional compensation behavior.
- Status outputs may indicate blanking-active and fault-latched conditions.

## Parameters and Configuration Knobs

- Dead-time count range and timing resolution.
- Number of phase-leg channels.
- Fault override priority and output-safe-state policy.
- Optional asymmetric dead time for turn-on versus turn-off transitions.

## Internal Architecture and Dataflow

The module usually contains transition detectors, delay counters, output-state machines, and fault gating. The contract must define whether dead time is inserted on both edges symmetrically and how simultaneous input toggles or faults are prioritized, because those choices affect both safety and waveform fidelity.

## Clocking, Reset, and Timing Assumptions

This block sits in the same timing domain as the PWM generator or a tightly synchronized derivative. Reset must force both outputs to the safe inactive state. If gate-driver delays differ by device or temperature, the configured dead time should include adequate margin or be recalibrated externally.

## Latency, Throughput, and Resource Considerations

Resource use is low, but correctness is non-negotiable. Dead-time resolution must be fine enough for the power stage switching speed, and added latency must be deterministic so later compensation blocks can account for it.

## Verification Strategy

- Verify non-overlap on all rising and falling switching combinations.
- Stress rapid duty changes, disable sequences, and asynchronous faults.
- Check that dead time never collapses below the configured minimum because of update timing.
- Confirm safe-state behavior during reset and after fault recovery.

## Integration Notes and Dependencies

Dead Time Inserter usually follows Center-Aligned PWM or Space Vector PWM outputs and drives the physical gate interface. It must integrate with Overcurrent Shutdown so protection can override the gate outputs immediately and predictably.

## Edge Cases, Failure Modes, and Design Risks

- Too little dead time can destroy the bridge; too much increases distortion and torque ripple.
- Asymmetric edge handling can create phase-current bias that is hard to diagnose.
- If fault priority is ambiguous, the power stage may not enter a safe state fast enough.

## Related Modules In This Domain

- center_aligned_pwm
- space_vector_pwm
- overcurrent_shutdown
- current_reconstruction

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Dead Time Inserter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
