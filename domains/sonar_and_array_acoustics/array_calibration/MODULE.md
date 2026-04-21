# Array Calibration

## Overview

Array Calibration manages channel correction data for a hydrophone array and applies or serves those corrections to other sonar processing modules. It is the structural bridge between laboratory characterization, field recalibration, and real-time array processing.

## Domain Context

Array calibration captures and applies the per-channel corrections that make sonar array processing believable. It encodes measured differences in gain, delay, phase, polarity, and sometimes position so beamforming and timing algorithms operate on a corrected model of the hydrophone aperture rather than an idealized but false one.

## Problem Solved

Even a well-built array exhibits sensor-to-sensor differences. If those offsets are ignored, beam peaks broaden, sidelobes rise, TDOA estimates bias, and long-term tracker performance degrades. Spreading calibration knowledge informally across multiple blocks makes those errors hard to audit and maintain.

## Typical Use Cases

- Applying fixed delay and gain corrections before delay-and-sum beamforming.
- Maintaining separate calibration tables for different frequency bands, tow configurations, or hardware revisions.
- Supporting tank-test procedures that compare measured and expected responses from a reference projector.
- Marking failed or suspect channels so beamforming and detection blocks can mute or deweight them.

## Interfaces and Signal-Level Behavior

- Control interfaces load calibration tables, activate profiles, and expose version or checksum metadata.
- Output interfaces may directly emit corrected samples or provide lookup results consumed by beamformers and TDOA engines.
- Status paths often report table validity, profile-active state, stale-calibration warnings, and flagged channels.
- Optional maintenance ports accept measured correction updates from a service processor or calibration routine.

## Parameters and Configuration Knobs

- Maximum channel count and number of stored calibration profiles.
- Correction precision for delay, gain, phase, and polarity terms.
- Whether corrections are applied inline to samples or delivered as sideband coefficients.
- Support for per-frequency-bin calibration versus a simpler broadband correction model.

## Internal Architecture and Dataflow

The module usually combines nonvolatile or loaded table storage, active-profile selection, correction arithmetic or coefficient distribution, and integrity checking. In deeper systems it also tracks calibration provenance so field operators can tell whether the active corrections came from factory characterization, recent self-test, or an emergency fallback profile.

## Clocking, Reset, and Timing Assumptions

Calibration data is only useful if channel identity and geometry mapping remain stable, so this block assumes the hydrophone interface exports a deterministic logical channel order. Profile changes should happen on safe boundaries, and reset should revert to a known valid profile or explicitly report no calibration loaded rather than silently passing bad defaults.

## Latency, Throughput, and Resource Considerations

Storage demands are modest, but inline correction can add multipliers, fractional delay filters, or per-channel scaling latency. Performance requirements are dominated by deterministic application of corrections to every active channel with no frame slippage, especially for larger arrays.

## Verification Strategy

- Apply known synthetic mismatches and confirm the reported or applied corrections restore the expected array response.
- Check profile switching, checksum failure, and missing-calibration cases to ensure faults are visible.
- Verify channel masks and polarity flips propagate to beamforming and TDOA consumers correctly.
- Run end-to-end beam pattern tests showing calibration improves mainlobe focus and sidelobe behavior as expected.

## Integration Notes and Dependencies

Array Calibration is consumed by Hydrophone Frontend Interface, Delay-and-Sum Beamformer, TDOA Estimator, and maintenance tooling. It should integrate with manufacturing records or field calibration utilities so the same correction data can be audited outside the FPGA and reapplied after firmware updates.

## Edge Cases, Failure Modes, and Design Risks

- Applying calibration with the wrong channel map can be worse than using no calibration at all.
- Stale profiles may quietly bias results after hardware replacement or array reconfiguration.
- If profile updates are not atomic, mixed old and new corrections can create transient but severe beam artifacts.

## Related Modules In This Domain

- hydrophone_frontend_interface
- delay_and_sum_beamformer
- tdoa_estimator
- bearing_estimator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Array Calibration module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
