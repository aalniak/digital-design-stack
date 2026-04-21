# Pulse Compression

## Overview

The pulse compression block applies matched filtering or equivalent processing to long coded or chirped pulses so range resolution improves without giving up transmit energy. It is a core range-focusing stage in many radar modes.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Long pulses improve energy on target but smear range response unless compression is applied on receive. This module provides that compression stage with an explicit waveform-reference contract.

## Typical Use Cases

- Compressing coded or chirped radar returns into narrow range responses.
- Improving range resolution while preserving transmit energy.
- Providing reusable matched-filter range processing in radar systems.

## Interfaces and Signal-Level Behavior

- Input side accepts coherent receive samples aligned to pulse or chirp boundaries.
- Reference side loads the expected transmit waveform or matched-filter coefficients.
- Output side emits compressed range-domain responses and optional sidelobe or validity telemetry.

## Parameters and Configuration Knobs

- Waveform length, coefficient precision, input width, and output accumulation width.
- Reference profile selection, normalization mode, and runtime waveform switching policy.
- Complex versus real mode and latency or overlap handling.

## Internal Architecture and Dataflow

The block correlates the received waveform against the expected transmit waveform, often using a matched filter or equivalent transform-based implementation, so the resulting output concentrates energy at the correct delay. The contract should define reference ordering, conjugation policy, and output lag convention relative to the input pulse boundary.

## Clocking, Reset, and Timing Assumptions

The input waveform and reference must share the documented sample rate, chirp law, and pulse framing. Reset should clear filter state and any overlap context between pulses.

## Latency, Throughput, and Resource Considerations

Pulse compression can be computationally heavy for long waveforms, especially in time-domain form, but it is central to range quality. Resource use depends on waveform length and whether the implementation is time- or frequency-domain.

## Verification Strategy

- Compare compressed responses against a matched-filter reference on synthetic delayed pulses and chirps.
- Check lag convention, coefficient ordering, and runtime waveform-profile switching.
- Verify reset and overlap behavior between successive pulses or chirps.

## Integration Notes and Dependencies

This block usually precedes range or detection logic and should be documented with the transmit waveform profile that defines its reference. Integrators should also note whether sidelobe control such as windowing is part of this block or a separate stage.

## Edge Cases, Failure Modes, and Design Risks

- A reference reversal or conjugation mistake can destroy compression gain while preserving numeric activity.
- Lag-convention mismatches can shift all downstream range indexing.
- Waveform-profile changes without pulse-boundary synchronization can corrupt several returns.

## Related Modules In This Domain

- matched_filter
- range_fft
- chirp_generator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pulse Compression module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
