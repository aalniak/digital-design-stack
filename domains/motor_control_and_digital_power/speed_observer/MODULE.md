# Speed Observer

## Overview

Speed Observer estimates mechanical or electrical speed from position feedback or other machine observables and emits a filtered speed signal with confidence or validity information. It is the bridge from discrete position events to stable speed feedback.

## Domain Context

The speed observer provides a filtered, control-ready estimate of rotor speed derived from position sensors, estimators, or model-based signals. In motor drives it smooths raw position differentiation into a speed quantity suitable for the outer control loop.

## Problem Solved

Directly differentiating raw position signals creates noise, quantization artifacts, and timing irregularities that can destabilize speed control. A dedicated observer or estimator provides a more robust speed signal tailored to the control bandwidth.

## Typical Use Cases

- Deriving speed from encoder, Hall, or resolver position updates.
- Smoothing sensorless angle estimates for use in the speed loop.
- Providing direction and near-zero-speed observability to supervisory logic.
- Supporting mode transitions between different feedback sources.

## Interfaces and Signal-Level Behavior

- Inputs are position updates, angle samples, transition periods, or observer inputs plus source-valid indicators.
- Outputs provide filtered speed, direction, and status such as near_zero or feedback_valid.
- Control registers configure filter constants, differentiation mode, and source selection.
- Diagnostic outputs may expose raw delta position, filtered speed, and source-health information.

## Parameters and Configuration Knobs

- Input angle or count precision.
- Filter depth or observer coefficient settings.
- Mechanical versus electrical speed output mode.
- Timeout thresholds for declaring missing or stale feedback.

## Internal Architecture and Dataflow

The block usually includes delta computation, wraparound handling, filtering or observer dynamics, and validity management. The domain-specific contract should define exactly which speed it reports, electrical or mechanical, because that distinction is easy to blur and critical for loop tuning.

## Clocking, Reset, and Timing Assumptions

The observer assumes timestamped or periodic position updates with a known timing basis. Reset clears accumulated history and filtered state. If multiple sources can be selected, switching policy and transient handling should be defined clearly.

## Latency, Throughput, and Resource Considerations

Computation is light, but signal quality matters greatly. Latency introduced by filtering must be balanced against noise reduction because the outer speed loop directly feels that tradeoff. Throughput follows the feedback-source update rate.

## Verification Strategy

- Replay known position trajectories and compare observed speed against a reference derivative or estimator.
- Stress wraparound, missing samples, and source switching.
- Check low-speed behavior where quantization is most challenging.
- Verify sign and unit conventions for both mechanical and electrical speed outputs.

## Integration Notes and Dependencies

Speed Observer feeds Speed Loop Controller and may also inform Soft Start Controller or protection logic. It should align with the position sensor path in use and with the pole-pair scaling assumed elsewhere in the control stack.

## Edge Cases, Failure Modes, and Design Risks

- Too much filtering can make the speed loop sluggish or unstable during fast transients.
- Electrical versus mechanical speed confusion can mis-tune every outer-loop gain.
- If invalid feedback is not flagged clearly, the controller may continue driving from nonsense data.

## Related Modules In This Domain

- speed_loop_controller
- hall_sensor_decoder
- quadrature_encoder_decoder
- resolver_interface

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Speed Observer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
