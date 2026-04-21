# Frequency Counter

## Overview

The frequency counter measures the rate of an input event stream relative to a reference time base and reports that measurement in digital form. It is a standard instrumentation primitive for clocks, pulses, and oscillatory signals.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

Frequency measurements seem simple, but gate timing, metastability, and update semantics matter when the result is used for calibration or control. This module provides a structured counter with clear timing and measurement-window definitions.

## Typical Use Cases

- Measuring clock or pulse frequency in lab and embedded instruments.
- Providing reference-discipline feedback to timing loops.
- Monitoring oscillator health or external event rates in deployed systems.

## Interfaces and Signal-Level Behavior

- Measurement side accepts the signal or edge stream being counted, often asynchronous to the system clock.
- Reference side supplies the measurement gate or time base.
- Output side emits count-based frequency estimates, validity flags, and optional overflow or out-of-range status.

## Parameters and Configuration Knobs

- Counter width, gate interval, asynchronous capture mode, and averaging behavior.
- Reciprocal versus direct-count measurement options if supported.
- Overflow handling and result-update cadence.

## Internal Architecture and Dataflow

The usual structure counts input edges during a known gate interval and then converts or reports that count as a frequency measurement. Variants may average over several intervals or use reciprocal timing for finer low-frequency resolution. The documentation should state whether the output is raw count, scaled frequency code, or both, and exactly when each result becomes valid.

## Clocking, Reset, and Timing Assumptions

The reference gate interval defines the measurement resolution, so its stability and units must be explicit. Reset should clear partial counts and any averaging state so the first reported measurement after reset is well defined.

## Latency, Throughput, and Resource Considerations

Frequency counting is light in logic cost, but asynchronous edge capture and wide counters can still affect implementation details. Measurement rate is determined by the chosen gate interval rather than datapath bandwidth.

## Verification Strategy

- Check count accuracy against known-frequency stimuli over a range of rates and gate lengths.
- Verify asynchronous-edge capture and overflow behavior.
- Confirm update timing and averaging semantics so software reads measurements at the right cadence.

## Integration Notes and Dependencies

This block often feeds calibration or timing loops, so the measurement window and scaling must be preserved with the interface documentation. Integrators should also state whether readings are instantaneous, averaged, or latched until read.

## Edge Cases, Failure Modes, and Design Risks

- A mismatch between assumed and actual gate duration creates systematic frequency error.
- Asynchronous edge handling mistakes may only appear at certain phase relationships.
- Software may misinterpret a raw count as a scaled frequency if the contract is vague.

## Related Modules In This Domain

- time_to_digital_capture
- digital_pll
- trigger_sequencer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Frequency Counter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
