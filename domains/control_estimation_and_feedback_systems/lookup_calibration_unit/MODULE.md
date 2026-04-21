# Lookup Calibration Unit

## Overview

The lookup calibration unit corrects or linearizes signals by mapping measured values through a stored calibration table or segmented transfer function. It is a practical bridge between ideal algorithms and imperfect sensors or actuators.

## Domain Context

Control, estimation, and feedback modules close loops around plant dynamics, sensors, and reference trajectories. In this domain the critical documentation topics are state update timing, saturation behavior, stability assumptions, fixed-point scaling, and how asynchronous events such as resets or coefficient changes interact with the loop state.

## Problem Solved

Real transducers and actuators are rarely perfectly linear or perfectly matched to ideal design equations. Calibration data must therefore be applied somewhere in the signal path, and that application should be explicit, testable, and reusable rather than embedded as arbitrary constants. This module provides that correction layer.

## Typical Use Cases

- Linearizing sensor outputs before control or estimation.
- Applying factory calibration to actuator commands or measured feedback.
- Providing a reusable correction stage in instrumentation and embedded control products.

## Interfaces and Signal-Level Behavior

- Input side accepts the raw value or code to be calibrated.
- Output side emits the corrected value and may report table index or interpolation status.
- Control side loads calibration tables, selects banks, or enables interpolation between entries.

## Parameters and Configuration Knobs

- Input and output widths, table depth, interpolation mode, and coefficient or entry precision.
- Support for multiple banks, signedness, and extrapolation policy outside the calibrated range.
- Runtime update behavior and memory interface style for the lookup data.

## Internal Architecture and Dataflow

The unit usually indexes a stored table using the input value or a derived region index and optionally interpolates between adjacent entries for smoother correction. Some implementations support piecewise-linear segments instead of dense tables. The documentation should state whether the block expects monotonic data, how out-of-range inputs are handled, and whether table updates take effect immediately or only at safe boundaries.

## Clocking, Reset, and Timing Assumptions

Calibration data is meaningful only for the specific hardware and units it was generated from, so provenance matters. Reset should select a documented default table or a known bypass state if calibration memory is not yet loaded.

## Latency, Throughput, and Resource Considerations

Lookup calibration is usually light to moderate in cost, with latency dominated by table memory access and optional interpolation arithmetic. Throughput can often remain one sample per cycle if the memory organization supports it.

## Verification Strategy

- Compare corrected outputs against source calibration data and interpolation expectations.
- Check out-of-range behavior, table-bank switching, and reset defaults.
- Verify monotonicity or boundedness if those properties are expected from the calibration map.

## Integration Notes and Dependencies

This module often lives near sensor acquisition or actuator command generation, and the exact placement changes system behavior. Integrators should document table ownership, update procedure, and whether software can inspect the active calibration data directly.

## Edge Cases, Failure Modes, and Design Risks

- Using calibration data from the wrong hardware revision can make the system consistently wrong while still appearing smooth.
- Out-of-range policy that is not documented can introduce unexpected clipping or extrapolation errors.
- If bank switching is not atomic, mixed calibration segments can appear during updates.

## Related Modules In This Domain

- kalman_filter_core
- adc_capture_interface
- dac_playback_interface

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Lookup Calibration Unit module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
