# Frequency Locked Loop

## Overview

The frequency locked loop aligns the frequency of a controlled oscillator or timing source to a reference without relying primarily on absolute phase alignment. It is particularly useful for coarse acquisition or systems where frequency error matters more immediately than phase offset.

## Domain Context

Control, estimation, and feedback modules close loops around plant dynamics, sensors, and reference trajectories. In this domain the critical documentation topics are state update timing, saturation behavior, stability assumptions, fixed-point scaling, and how asynchronous events such as resets or coefficient changes interact with the loop state.

## Problem Solved

Some synchronization tasks begin with significant frequency mismatch, making a PLL alone slow or fragile during acquisition. An FLL provides a more direct frequency-correction path and can stand alone or assist a PLL. This module captures that reusable loop behavior.

## Typical Use Cases

- Coarse acquisition of oscillators before handoff to a tighter PLL.
- Tracking long-term frequency drift against a reference pulse train or phase detector.
- Stabilizing sample-clock or carrier frequency in measurement and communications systems.

## Interfaces and Signal-Level Behavior

- Reference side provides frequency or phase-difference observations from which frequency error can be inferred.
- Control side updates an oscillator or phase-increment source.
- Status side reports estimated frequency error, lock state, and range-limit conditions.

## Parameters and Configuration Knobs

- Loop gain, estimator precision, and update interval.
- Frequency-word width, lock thresholds, and acquisition or tracking mode options.
- Holdover support and saturation limits for correction values.

## Internal Architecture and Dataflow

An FLL estimates the difference between actual and desired frequency from observations across time and filters that estimate into a control word for the oscillator. Depending on the implementation, it may derive error from phase growth, interval measurement, or edge timing. The contract should explain exactly how lock is defined and whether the loop can converge with large phase offset present.

## Clocking, Reset, and Timing Assumptions

The observation interval and error units must be matched to the oscillator control resolution. Reset should initialize the oscillator control word to a documented starting frequency for predictable acquisition behavior.

## Latency, Throughput, and Resource Considerations

The arithmetic cost is light to moderate, but practical performance is determined by acquisition speed, noise sensitivity, and residual frequency error. Precision planning matters because fine frequency resolution is often the point of the loop.

## Verification Strategy

- Check convergence from large initial frequency offsets against a numerical loop reference.
- Verify lock declaration and saturation behavior near correction limits.
- Confirm handoff behavior if the FLL is intended to feed or cooperate with a PLL.

## Integration Notes and Dependencies

This module is often part of a staged synchronization strategy rather than a standalone timing block. Integrators should document whether it runs continuously, only during acquisition, or in parallel with another loop.

## Edge Cases, Failure Modes, and Design Risks

- If the FLL and PLL disagree about control-word ownership, the combined system can fight itself.
- Too much gain can make frequency estimates noisy and unstable.
- A vague lock definition can leave higher-level logic unsure when acquisition is complete.

## Related Modules In This Domain

- digital_pll
- digital_dll
- frequency_counter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Frequency Locked Loop module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
