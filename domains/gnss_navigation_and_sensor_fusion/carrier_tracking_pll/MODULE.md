# Carrier Tracking PLL

## Overview

Carrier Tracking PLL estimates and corrects carrier phase error for a tracked satellite channel, driving a local oscillator or carrier NCO toward phase lock. It stabilizes the baseband replica so coherent correlation remains strong over time.

## Domain Context

The carrier tracking PLL is the fine phase-lock mechanism that keeps a GNSS receiver aligned to the carrier of a tracked satellite after acquisition. It is central to coherent integration, navigation-bit demodulation, and high-quality carrier-phase measurements.

## Problem Solved

After acquisition, the receiver still needs continuous carrier alignment despite oscillator error, Doppler shift, and platform dynamics. Without a dedicated PLL, coherent gain collapses quickly and later navigation observables become noisy or unusable.

## Typical Use Cases

- Maintaining carrier lock after acquisition on a moving platform.
- Supporting coherent integrations needed for weak-signal tracking.
- Providing phase-error information to carrier-phase measurement blocks.
- Handing off from an FLL-assisted pull-in mode to a tighter steady-state tracking mode.

## Interfaces and Signal-Level Behavior

- Inputs usually include prompt I/Q correlations, loop-enable controls, and carrier NCO state or adjustment interface.
- Outputs provide phase error, lock indicators, and updated carrier frequency or phase correction commands.
- Control registers configure loop bandwidth, damping, discriminator type, and aiding modes.
- Diagnostic signals may expose discriminator output, filtered loop state, and cycle-slip flags.

## Parameters and Configuration Knobs

- Phase accumulator width and carrier NCO resolution.
- Supported discriminator family and loop filter coefficient precision.
- Lock thresholds, aided mode enables, and bandwidth settings.
- Number of tracking channels instantiated in parallel.

## Internal Architecture and Dataflow

A standard architecture contains a phase discriminator, loop filter, and NCO control path. In GNSS the module contract should state whether it is a pure PLL or part of a hybrid FLL-assisted strategy, because acquisition handoff and dynamic stress tolerance depend strongly on that choice.

## Clocking, Reset, and Timing Assumptions

The loop assumes acquisition has provided a sufficiently close initial Doppler and phase estimate for pull-in. Reset clears loop integrators and lock state. If navigation-bit transitions affect the discriminator, the design should document how bit sign is handled or aided.

## Latency, Throughput, and Resource Considerations

Tracking loops are arithmetic-light but numerically sensitive. Throughput aligns with the correlation update rate, while stability depends on coefficient scaling and phase representation. Latency must remain low enough that loop delay does not destabilize the chosen bandwidth.

## Verification Strategy

- Check pull-in and steady-state lock against synthetic Doppler and phase trajectories.
- Stress dynamic motion, oscillator bias, and weak-signal cases near the lock threshold.
- Verify cycle-slip detection and lock-indicator behavior.
- Compare loop response against a high-level control reference for selected bandwidth settings.

## Integration Notes and Dependencies

Carrier Tracking PLL follows acquisition or FLL-assisted pull-in and feeds Carrier Phase Engine, Nav Bit Synchronizer, and channel status reporting. It should align with Code Tracking DLL update cadence so both loops operate on the same correlation timing basis.

## Edge Cases, Failure Modes, and Design Risks

- A stable-looking but biased phase loop can corrupt carrier-phase observables subtly.
- Too much loop delay can cause marginal instability that only appears under dynamics.
- If bit sign transitions are mishandled, the PLL may lose lock intermittently.

## Related Modules In This Domain

- frequency_locked_loop
- carrier_phase_engine
- code_tracking_dll
- nav_bit_synchronizer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Carrier Tracking PLL module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
