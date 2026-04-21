# Current Reconstruction

## Overview

Current Reconstruction derives phase or alpha-beta current values from available shunt or sensor measurements and known switching state. It provides the current feedback observables required by field-oriented control and protection logic.

## Domain Context

Current reconstruction is the sensing-side companion to PWM modulation in motor drives. When hardware measures only one or two shunt currents or samples during limited windows, this block reconstructs the full phase-current state needed by control loops.

## Problem Solved

Many drive topologies cannot measure all phase currents directly at every instant. Without a dedicated reconstruction block, control loops end up using inconsistent sensing assumptions, and certain PWM sectors or low-duty windows become poorly handled.

## Typical Use Cases

- Reconstructing three-phase currents from two-shunt inverter measurements.
- Producing synchronized current estimates for FOC current loops.
- Masking invalid sampling windows created by dead time or switching noise.
- Supporting sensing diagnostics during low-duty or overmodulation operating points.

## Interfaces and Signal-Level Behavior

- Inputs typically include ADC current samples, PWM sector or switching-state metadata, and sampling-valid indicators.
- Outputs provide reconstructed phase currents, transformed current quantities, and validity flags.
- Control registers configure sensor polarity, shunt topology, calibration offsets, and invalid-window policy.
- Diagnostic outputs may expose saturated samples, skipped reconstructions, and per-phase offset estimates.

## Parameters and Configuration Knobs

- Number and topology of current sensors.
- ADC sample precision and offset-compensation width.
- Supported reconstruction mode for one-shunt, two-shunt, or direct three-shunt hardware.
- Window-valid thresholds tied to duty limits and dead-time margins.

## Internal Architecture and Dataflow

The block usually combines offset correction, switching-state interpretation, algebraic phase-current reconstruction, and invalid-sample handling. The key contract is not just the math but when the result is considered trustworthy, because control stability depends on knowing when sensed current is valid versus extrapolated or unavailable.

## Clocking, Reset, and Timing Assumptions

Current Reconstruction assumes tight time alignment between ADC samples and PWM state. Reset clears calibration and validity history. If sample windows are generated externally, their timing relative to dead time and switching edges must match the documented reconstruction model.

## Latency, Throughput, and Resource Considerations

Arithmetic cost is moderate, but latency must fit comfortably within the control-loop budget. Accuracy is dominated more by sensing alignment and offset calibration than raw compute precision. Throughput follows the PWM or ADC sample cadence.

## Verification Strategy

- Inject synthetic phase currents and switching states to verify exact reconstruction under each sector.
- Stress invalid sampling windows, low-duty operation, and offset drift.
- Check validity signaling so the current loop can react appropriately to missing or poor-quality measurements.
- Compare reconstructed currents against a full three-sensor reference in simulation or replay data.

## Integration Notes and Dependencies

Current Reconstruction feeds Clarke Transform, FOC Current Loop, and protection logic. It must integrate with PWM timing, ADC triggering, and dead-time policies because any mismatch in those three can invalidate the inferred current vector.

## Edge Cases, Failure Modes, and Design Risks

- A valid-looking but wrong reconstruction can destabilize the current loop quickly.
- Ignoring invalid windows near duty extremes can create severe estimation error.
- Offset calibration mistakes can look like motor saliency or parameter mismatch rather than sensing failure.

## Related Modules In This Domain

- clarke_transform
- foc_current_loop
- center_aligned_pwm
- dead_time_inserter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Current Reconstruction module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
