# Multi Return Resolver

## Overview

Multi Return Resolver takes candidate peaks from a ranging profile and decides which returns should be preserved, merged, ranked, or discarded for downstream geometry generation. It turns raw multipeak evidence into a stable contract for consumers that expect one or more physical surfaces per shot.

## Domain Context

Multi-return resolution exists because many LiDAR scenes are not single-surface problems. Vegetation, fences, rain, dust, and semi-transparent materials can all create several valid returns from one emitted shot, and the ranging stack needs a principled way to preserve or rank that structure instead of collapsing it blindly.

## Problem Solved

Peak detectors can report several plausible surfaces, but not all downstream blocks can consume arbitrary candidate lists. A resolver is needed to separate genuine layered structure from noise shoulders and multipath artifacts while keeping ordering, quality, and policy explicit.

## Typical Use Cases

- Preserving first and last returns through vegetation canopies.
- Separating foreground fence wires from background surfaces in mobile scanning.
- Dropping weak secondary peaks that are likely caused by internal reflections or histogram noise.
- Providing ranked surface candidates to host software that chooses a mission-specific return policy.

## Interfaces and Signal-Level Behavior

- Inputs are peak lists with position, amplitude, width, and confidence metadata per shot or channel.
- Outputs provide an ordered set of accepted returns, usually including return index, calibrated position estimate, and quality flags.
- Control registers define acceptance policy such as strongest-only, earliest-plus-strongest, or up to N valid returns.
- Diagnostic outputs may expose rejected candidates and the reason each was filtered or merged.

## Parameters and Configuration Knobs

- Maximum number of returns emitted per measurement.
- Minimum separation and prominence required for distinct surfaces.
- Merge policy for overlapping or closely spaced peaks.
- Ranking preference among earliest, strongest, narrowest, or confidence-weighted returns.

## Internal Architecture and Dataflow

This block commonly contains a candidate sorter, separation and quality filters, a merge stage for overlapping peaks, and a formatter that emits a bounded return list. The important domain contract is that return ordering and tie-breaking rules are deterministic so host-side mapping or perception does not see unstable surface identities across adjacent shots.

## Clocking, Reset, and Timing Assumptions

Peak inputs are assumed to be generated from a consistent bin-to-distance model and to include enough confidence information for filtering. Reset clears any residual per-frame candidate state. If operating in frame-based imagers, the resolver should not mix candidates across pixels or frame boundaries.

## Latency, Throughput, and Resource Considerations

Computation is light relative to histogram building, but throughput must sustain the full shot or pixel rate because it sits directly on the geometry path. Resource use mainly depends on the maximum number of candidate peaks stored and sorted per measurement.

## Verification Strategy

- Feed synthetic multi-surface profiles and confirm accepted returns follow the documented ranking policy.
- Stress near-merged peaks, weak secondary peaks, and high-background conditions.
- Verify deterministic ordering across repeated runs of the same ambiguous input.
- Check that rejected-return diagnostics match the actual filtering reason.

## Integration Notes and Dependencies

Multi Return Resolver typically follows Peak Detector and feeds Range Calibration Engine, Point Cloud Packer, and host telemetry. It should align with the perception stack on what first, last, and strongest return mean operationally so no semantic mismatch appears later.

## Edge Cases, Failure Modes, and Design Risks

- A poor tie-breaking policy can make surfaces flicker between return slots from shot to shot.
- Overzealous merging may erase thin structures that are operationally important.
- If return ordering is not documented precisely, downstream perception may interpret the wrong surface as ground or obstacle.

## Related Modules In This Domain

- peak_detector
- range_calibration_engine
- point_cloud_packer
- reflectivity_estimator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Multi Return Resolver module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
