# Frequency Locked Loop

## Overview

Frequency Locked Loop estimates carrier frequency error from successive correlation phases or related observables and nudges the local carrier replica toward the correct Doppler. It is primarily used for pull-in, reacquisition, or aiding under difficult dynamics.

## Domain Context

The frequency locked loop provides robust frequency pull-in and assistance for GNSS tracking under larger initial Doppler uncertainty or weak carrier-phase observability. It is often the stabilizing bridge between coarse acquisition and fine PLL tracking.

## Problem Solved

A PLL alone may be too fragile when initial carrier frequency error is large or phase coherence is poor. An FLL provides a more forgiving tracking mode that can acquire usable frequency alignment before the receiver attempts tighter phase lock.

## Typical Use Cases

- Assisting post-acquisition carrier pull-in before PLL lock.
- Maintaining coarse frequency tracking under weak or rapidly changing dynamics.
- Recovering from temporary phase loss without restarting the full acquisition search.
- Providing frequency estimates to channel management and diagnostics.

## Interfaces and Signal-Level Behavior

- Inputs typically include successive prompt correlations, loop control enables, and carrier NCO state.
- Outputs provide frequency error estimates, lock metrics, and frequency correction commands.
- Controls configure discriminator type, bandwidth, and handoff policy to the PLL.
- Diagnostic outputs may expose short-term frequency estimates and loss-of-lock conditions.

## Parameters and Configuration Knobs

- Frequency discriminator resolution and loop filter coefficient precision.
- Carrier NCO width and supported Doppler range.
- Bandwidth and damping settings for pull-in versus steady-state modes.
- Handoff thresholds used when transitioning control to the PLL.

## Internal Architecture and Dataflow

This block usually contains a frequency discriminator, loop filter, and NCO update path similar to a PLL but optimized for frequency rather than absolute phase. The architectural contract should document whether the loop runs independently, in parallel with the PLL, or only during specific channel states.

## Clocking, Reset, and Timing Assumptions

The FLL assumes enough signal continuity between updates to estimate phase-rate meaningfully. Reset clears loop history and previous-correlation memory. If combined with a PLL, the sign and scaling conventions of both loops must match exactly at handoff boundaries.

## Latency, Throughput, and Resource Considerations

Resource cost is low, but update-to-update numerical stability matters. Latency must remain small relative to the correlation cadence so discriminator estimates are timely. Robustness under noisy correlation updates is usually the limiting performance factor.

## Verification Strategy

- Inject known Doppler ramps and confirm frequency pull-in and steady-state error behavior.
- Exercise PLL handoff conditions to ensure no discontinuity destabilizes the channel.
- Verify loss-of-lock and reacquisition assistance logic under weak-signal fades.
- Compare discriminator output against a software model over representative dynamics.

## Integration Notes and Dependencies

Frequency Locked Loop works alongside Acquisition Correlator Bank and Carrier Tracking PLL. It should integrate with channel state management so software knows when a channel is in pull-in, assisted tracking, or fully phase-locked mode.

## Edge Cases, Failure Modes, and Design Risks

- A mismatched handoff between FLL and PLL can cause oscillation or relock churn.
- Poor frequency discriminator scaling may appear fine in static tests but fail under dynamics.
- If lock metrics are misleading, channel management may hold onto unusable tracks too long.

## Related Modules In This Domain

- carrier_tracking_pll
- acquisition_correlator_bank
- carrier_phase_engine
- nav_bit_synchronizer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Frequency Locked Loop module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
