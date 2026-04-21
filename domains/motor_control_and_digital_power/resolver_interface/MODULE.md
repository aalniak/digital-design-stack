# Resolver Interface

## Overview

Resolver Interface captures or receives resolver-derived position data and converts it into usable electrical angle, speed, and health information for control loops. It packages robust analog position sensing into a digital control contract.

## Domain Context

Resolver interfaces bridge analog rotor-position sensing into the digital motor-control domain. They are common in high-reliability or harsh-environment drives where resolver robustness is preferred over optical or Hall sensing.

## Problem Solved

Resolvers require excitation, demodulation, and careful angle extraction. Even when some of that is handled externally, the digital control stack still needs a well-defined interface for angle, speed, and fault reporting. A dedicated module keeps that contract explicit.

## Typical Use Cases

- Receiving digital angle data from a resolver-to-digital front end.
- Supporting high-reliability rotor position feedback in industrial drives.
- Monitoring resolver health and signal-quality diagnostics.
- Providing angle and speed information for FOC and field weakening.

## Interfaces and Signal-Level Behavior

- Inputs may be angle words, sine-cosine samples, validity strobes, and fault indicators from a resolver front end.
- Outputs provide electrical angle, derived speed, validity, and fault status.
- Control registers configure pole-pair scaling, angle offset, interpolation, and fault thresholds.
- Diagnostic outputs may expose amplitude imbalance, tracking errors, or stale-sample indicators when available from the front end.

## Parameters and Configuration Knobs

- Angle resolution and update cadence.
- Mechanical-to-electrical angle scaling and offset precision.
- Speed derivation filter depth.
- Supported resolver front-end data format or protocol mode.

## Internal Architecture and Dataflow

The interface typically includes angle conditioning, optional offset correction, electrical-angle scaling, and quality propagation. The contract should separate what is guaranteed by the external resolver converter from what this digital block derives locally, because those responsibilities vary widely across systems.

## Clocking, Reset, and Timing Assumptions

The resolver front end is assumed to provide stable samples or already-demodulated angle estimates at the documented rate. Reset clears speed derivation history and validity state. If angle samples can be stale or discontinuous, the interface must surface that to the control loop.

## Latency, Throughput, and Resource Considerations

Arithmetic cost is modest. Latency matters because the angle feeds fast control loops, but the bigger requirement is consistent update timing and honest validity reporting. Speed derivation quality often depends more on filtering policy than on datapath width.

## Verification Strategy

- Inject synthetic angle trajectories and verify electrical-angle scaling and offset application.
- Stress wraparound, stale data, and reported fault conditions.
- Check derived speed against known angle ramps.
- Validate polarity and sign conventions with representative motor parameter settings.

## Integration Notes and Dependencies

Resolver Interface feeds Park and Inverse Park transforms, Speed Observer, and startup logic. It must align with machine pole-pair configuration and with any fallback sensor path such as Hall or encoder feedback.

## Edge Cases, Failure Modes, and Design Risks

- A mechanical-to-electrical scaling mistake can make the entire FOC loop operate on the wrong angle.
- If stale resolver data is not surfaced, the current loop may act on outdated position.
- Ambiguous fault semantics can cause unnecessary shutdowns or, worse, unsafe continued operation.

## Related Modules In This Domain

- speed_observer
- park_transform
- inverse_park_transform
- soft_start_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Resolver Interface module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
