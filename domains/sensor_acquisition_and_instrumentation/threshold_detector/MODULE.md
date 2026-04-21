# Threshold Detector

## Overview

The threshold detector compares a signal or measurement against configured limits and emits structured detection results when those limits are crossed or held. It is one of the most common primitives for turning analog-like behavior into digital decisions.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

Thresholding appears simple, but hysteresis, holdoff, polarity, and sample-to-event timing all matter in real instruments. This module defines that decision boundary explicitly so detection results are stable and reusable across systems.

## Typical Use Cases

- Detecting amplitude crossings in sampled waveforms.
- Building level-triggered alarms, hit detectors, or comparator-like digital events.
- Supporting calibration and adaptive-threshold workflows with a consistent hardware contract.

## Interfaces and Signal-Level Behavior

- Input side accepts the value to be tested plus optional qualifiers.
- Output side emits threshold-hit pulses, sustained-state flags, and optional sign or crossing-direction metadata.
- Control side sets thresholds, hysteresis, polarity, and holdoff or debounce policy.

## Parameters and Configuration Knobs

- Input width, upper and lower thresholds, hysteresis enable, and signedness.
- Crossing-only versus level-sensitive mode and holdoff length.
- Runtime programmability and output pulse or latch behavior.

## Internal Architecture and Dataflow

The detector compares each accepted input against one or more thresholds and updates event or state outputs according to the configured mode. Hysteresis variants remember recent state to avoid chattering near the threshold. The important contract point is whether outputs report instantaneous in-range state, edge crossings, or both.

## Clocking, Reset, and Timing Assumptions

Threshold values are meaningful only in the scaling of the incoming signal, so unit conventions should remain visible with the module. Reset should initialize any hysteresis or latch state deterministically.

## Latency, Throughput, and Resource Considerations

Threshold logic is small and usually supports full-rate streaming easily. Resource use depends mostly on how much state and qualification logic accompanies the comparison.

## Verification Strategy

- Check exact-threshold, just-below, and just-above behavior for both polarities.
- Verify hysteresis, holdoff, and crossing-direction reporting under noisy inputs.
- Confirm reset and threshold updates do not create false detections unless documented.

## Integration Notes and Dependencies

This block often feeds event detectors, trigger sequencers, and counters, so the event definition should stay consistent across those neighbors. Integrators should also document whether the thresholds are static, software-managed, or calibration-driven.

## Edge Cases, Failure Modes, and Design Risks

- A one-code threshold interpretation error can bias detection rates significantly in sensitive systems.
- If hysteresis behavior is not documented, software may misread the meaning of a latched state.
- Threshold updates midstream can create spurious hits if not coordinated.

## Related Modules In This Domain

- event_detector
- histogram_engine
- trigger_sequencer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Threshold Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
