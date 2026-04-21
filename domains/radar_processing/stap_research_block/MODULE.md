# STAP Research Block

## Overview

The STAP research block supports space-time adaptive processing experiments by providing a configurable stage for joint spatial-temporal interference suppression or target enhancement. It is explicitly positioned as research infrastructure rather than a fixed production algorithm.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Advanced radar experiments often need flexible spatial-temporal adaptation that does not fit a stable production IP contract. This module offers a contained place for that exploration while keeping the input and output semantics documented.

## Typical Use Cases

- Exploring space-time interference suppression in array radar research.
- Testing adaptive clutter and jammer mitigation ideas in hardware-assisted form.
- Providing a sandboxed advanced-processing stage in experimental radar chains.

## Interfaces and Signal-Level Behavior

- Input side accepts coherent array data across pulses, chirps, or slow-time windows.
- Output side emits processed cells or candidate suppression metrics plus optional debug visibility.
- Control side loads weights, covariance surrogates, or experiment profile parameters.

## Parameters and Configuration Knobs

- Channel count, slow-time depth, coefficient precision, and output format.
- Adaptive versus fixed-weight mode, debug-visibility depth, and runtime experiment profile selection.
- Input window dimensions and reset or retraining policy.

## Internal Architecture and Dataflow

The block is intentionally broader and more experimental than fixed-function radar stages, but it still operates on documented space-time data windows and emits a processed result under a selected profile. The contract should clearly state whether the block performs full adaptation internally or consumes externally computed weights. It should also identify any aspects that are research-only and not stable production behavior.

## Clocking, Reset, and Timing Assumptions

The input windows must preserve coherent spatial and temporal ordering exactly as documented. Reset should clear adaptive or experimental state to a well-defined baseline before each experiment run or frame, as appropriate.

## Latency, Throughput, and Resource Considerations

Cost depends heavily on the selected experimental mode and can range from moderate to very heavy. Resource use is intentionally profile dependent and should be treated as experimental rather than fixed.

## Verification Strategy

- Compare selected profile outputs against a trusted reference for the corresponding experimental mode.
- Check window ordering, profile switching, and debug-output semantics.
- Verify reset or retraining behavior so experiments begin from known conditions.

## Integration Notes and Dependencies

This block should be integrated with explicit research-only warnings and strong versioning of profile meaning. Integrators should preserve experiment metadata with any results generated downstream.

## Edge Cases, Failure Modes, and Design Risks

- Because this block is research-oriented, undocumented profile changes can invalidate comparisons across runs.
- Adaptive-state persistence may create irreproducible behavior if reset policy is not explicit.
- Downstream teams may assume production stability where only experimental semantics exist.

## Related Modules In This Domain

- clutter_suppressor
- micro_doppler_analyzer
- array_calibration

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the STAP Research Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
