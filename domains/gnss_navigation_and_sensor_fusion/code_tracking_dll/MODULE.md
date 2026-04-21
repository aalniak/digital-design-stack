# Code Tracking DLL

## Overview

Code Tracking DLL estimates code-phase error from early, prompt, and late correlations and adjusts the local code replica so correlation remains centered on the received spreading code. It is the primary control loop behind continuous pseudorange observability.

## Domain Context

The code tracking DLL keeps the locally generated spreading code aligned with the incoming GNSS signal after acquisition. It is the loop that maintains accurate code phase, which directly affects pseudorange precision.

## Problem Solved

Even after acquisition, code phase drifts because of oscillator error, Doppler, and motion. Without a dedicated DLL, prompt correlation degrades, pseudorange becomes noisy, and the rest of the navigation solution loses one of its core observables.

## Typical Use Cases

- Maintaining code lock after initial acquisition.
- Supporting precise pseudorange extraction from prompt code phase.
- Operating jointly with the carrier loop in standard GNSS channel tracking.
- Providing lock quality information for channel health and measurement weighting.

## Interfaces and Signal-Level Behavior

- Inputs include early, prompt, and late correlation values plus code NCO state or update interface.
- Outputs provide code-phase error, lock indicators, and updated code rate or phase correction commands.
- Controls configure discriminator type, early-late spacing, loop bandwidth, and aiding options.
- Diagnostic signals may expose correlator magnitudes, filtered loop state, and code epoch markers.

## Parameters and Configuration Knobs

- Code NCO resolution and phase accumulator width.
- Early-late spacing options and discriminator selection.
- Loop filter coefficient precision and bandwidth settings.
- Number of channels tracked in parallel.

## Internal Architecture and Dataflow

A typical DLL contains a code discriminator, loop filter, and code NCO update path. The domain-specific contract should state the spacing and error convention explicitly because pseudorange interpretation and loop tuning depend on those details.

## Clocking, Reset, and Timing Assumptions

The DLL assumes acquisition provided a sufficiently close starting code phase. Reset clears integrators and lock state. If carrier aiding or Doppler aiding is used, the interface and scaling of that aid should be documented clearly.

## Latency, Throughput, and Resource Considerations

This loop is light in logic cost but sensitive to fixed-point scaling and update latency. Throughput follows the correlation rate, and deterministic latency is important to keep loop dynamics predictable.

## Verification Strategy

- Check pull-in and steady-state code error for synthetic code delays and Doppler.
- Verify discriminator scaling for each supported early-late spacing.
- Stress weak-signal and dynamic cases to measure code-lock robustness.
- Compare loop response against a software reference with the same fixed-point settings.

## Integration Notes and Dependencies

Code Tracking DLL consumes correlator outputs and PRN Generator timing while feeding Pseudorange Engine and channel health logic. It should coordinate with Carrier Tracking PLL and FLL so aiding paths and correlation timing are consistent.

## Edge Cases, Failure Modes, and Design Risks

- An undocumented change in early-late spacing can shift loop behavior and pseudorange noise dramatically.
- Poor fixed-point scaling may make the loop appear stable until low-SNR conditions.
- If code epoch markers are ambiguous, later measurement extraction can be biased.

## Related Modules In This Domain

- prn_generator
- acquisition_correlator_bank
- pseudorange_engine
- carrier_tracking_pll

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Code Tracking DLL module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
