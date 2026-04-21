# Digital Lock-In Amplifier

## Overview

The digital lock-in amplifier extracts the amplitude and phase of a signal component at a known reference frequency by coherent mixing and low-pass filtering. It is a classic measurement primitive for weak-signal detection in noise.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

When the signal of interest is small relative to broadband noise, direct amplitude measurement is unreliable. A lock-in amplifier isolates the component coherent with a reference, but the reference phase, filtering, and scaling must be handled very carefully in hardware. This module packages that coherent measurement path.

## Typical Use Cases

- Measuring weak periodic signals in instrumentation and sensing setups.
- Extracting phase and amplitude relative to an excitation reference.
- Providing reusable coherent detection in optics, acoustics, and lab automation systems.

## Interfaces and Signal-Level Behavior

- Input side accepts the measured sample stream and usually a coherent reference or phase-control input.
- Output side emits I and Q accumulation results, amplitude or phase estimates, and valid timing tied to the measurement window.
- Control side configures reference frequency or phase, integration time, and output format.

## Parameters and Configuration Knobs

- Input width, reference precision, integration window length, and output scaling.
- Real versus complex input mode, low-pass filter configuration, and phase-offset support.
- Windowing or decimation options for the measurement result cadence.

## Internal Architecture and Dataflow

A digital lock-in typically multiplies the incoming signal by in-phase and quadrature references, low-pass filters or integrates the products, and then optionally converts the result to magnitude and phase. The measurement quality depends strongly on reference coherence and integration-window design. The documentation should state whether outputs are raw integrated values, averaged values, or already converted to polar form.

## Clocking, Reset, and Timing Assumptions

The reference must be coherent with the signal component being measured, and the output meaning depends on the integration time relative to the sample rate. Reset should clear the integrator state so measurement windows restart cleanly.

## Latency, Throughput, and Resource Considerations

Most of the work is moderate-rate multiply-accumulate and filtering. Resource cost depends on reference generation, integration length, and whether amplitude or phase post-processing is included.

## Verification Strategy

- Compare amplitude and phase recovery against a reference model across phase offsets and SNR conditions.
- Verify integration-window timing and reset behavior.
- Check scaling conventions so software interprets raw or averaged outputs correctly.

## Integration Notes and Dependencies

This module often sits in a measurement chain with an excitation source or reference oscillator, so the phase convention between those blocks must be documented. Integrators should also record whether outputs are updated every sample, every window, or both.

## Edge Cases, Failure Modes, and Design Risks

- A phase-reference convention mismatch can rotate I and Q results and confuse downstream interpretation.
- Window-length assumptions that differ from software expectations can make measured amplitudes appear inconsistent.
- If the reference is not coherent, the block will fail gracefully but misleadingly by averaging away the desired signal.

## Related Modules In This Domain

- digital_mixer
- numerically_controlled_oscillator
- histogram_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Digital Lock-In Amplifier module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
