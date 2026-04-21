# Numerically Controlled Oscillator

## Overview

The numerically controlled oscillator generates a programmable sinusoidal or complex exponential reference from digital phase accumulation. It is a standard carrier and timing primitive for mixers, modulators, lock-in amplifiers, and waveform synthesis.

## Domain Context

DSP and sampled-data processing modules operate on numerically structured streams where timing regularity, coefficient interpretation, and spectral behavior matter as much as raw logic correctness. In this domain the most important documentation themes are fixed-point scaling, streaming cadence, filter state management, latency, and how algorithmic intent maps onto hardware structure.

## Problem Solved

Many digital systems need a tunable and phase-coherent carrier source, but bespoke implementations often hide phase-wrap rules, frequency tuning resolution, and reset behavior. This module centralizes those details into a reusable oscillator with a clear numeric contract.

## Typical Use Cases

- Driving digital mixers in DDC and DUC chains.
- Generating quadrature references for lock-in analysis or modulation.
- Providing deterministic phase-continuous test tones and carrier sources in laboratory hardware.

## Interfaces and Signal-Level Behavior

- Control side accepts a phase increment, optional phase offset, and enable or reset control.
- Output side emits real sinusoid, cosine and sine pair, or a packed complex carrier stream.
- Status or debug side may expose phase accumulator state or overflow pulses for synchronization.

## Parameters and Configuration Knobs

- Phase accumulator width, output amplitude width, and LUT or CORDIC generation method.
- Support for phase offsets, dither, and real versus complex output modes.
- Reset and tuning-update policy, including whether phase continuity is preserved across writes.

## Internal Architecture and Dataflow

An NCO accumulates phase by adding a tuning word each update cycle and maps the resulting phase to amplitude using a lookup table, CORDIC, or hybrid approximation. The larger the accumulator, the finer the tuning resolution. The documentation should explain whether output amplitude is normalized, how the quadrature pair is phased, and what happens to phase continuity when the tuning word changes.

## Clocking, Reset, and Timing Assumptions

The output frequency depends on the update rate exactly, so sample-clock assumptions belong alongside the module. Reset policy should specify whether the oscillator restarts at a known phase or resumes continuity after enable gating.

## Latency, Throughput, and Resource Considerations

NCOs are usually small and can operate at one sample per cycle, though high-precision phase-to-amplitude conversion may require pipelining. Resource cost depends on accumulator width and waveform-generation method.

## Verification Strategy

- Check generated frequency and phase progression against a numerical reference over several tuning words.
- Verify quadrature relationships and phase-offset behavior.
- Confirm tuning updates and resets follow the documented continuity policy.

## Integration Notes and Dependencies

This block often anchors coherent signal chains, so its phase convention must be kept consistent with mixers, beamformers, and calibration logic. Integrators should also decide whether phase accumulator visibility is needed for deterministic multi-channel startup.

## Edge Cases, Failure Modes, and Design Risks

- A hidden sign or quadrature convention mismatch can invert sidebands later in the chain.
- Coarse amplitude or phase quantization may create spurs that matter in precision systems.
- If tuning updates silently reset phase, coherent processing across channels may fail.

## Related Modules In This Domain

- digital_mixer
- ddc_chain
- duc_chain

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Numerically Controlled Oscillator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
