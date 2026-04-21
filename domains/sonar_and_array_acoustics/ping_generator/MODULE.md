# Ping Generator

## Overview

Ping Generator creates the digital transmit waveform definition for an active sonar shot. It turns host-programmed timing and waveform parameters into a deterministic sample stream or event schedule that downstream DAC, modulator, and power-stage logic can consume without ambiguity.

## Domain Context

The ping generator sits at the front edge of an active sonar transmit chain. In this domain it is responsible for synthesizing or sequencing the acoustic excitation waveform that will later be projected through a power amplifier and transducer, with enough control over pulse width, coding, and repetition rate to support range estimation, matched filtering, and regulatory or platform power limits.

## Problem Solved

Active sonar depends on repeatable transmit signatures. Without a dedicated ping generator, pulse length, phase coding, chirp slope, guard times, and shot cadence tend to be scattered across software and glue logic, which makes matched filtering harder, breaks calibration repeatability, and increases the risk of over-driving the acoustic front end.

## Typical Use Cases

- Emitting short CW or chirped pings for range finding and target localization.
- Scheduling coded pulse trains used with matched-filter gain in low-SNR underwater channels.
- Generating repeatable calibration shots for tank tests, array alignment, and transducer health monitoring.
- Driving burst schedules in multistatic or mechanically scanned sonar experiments.

## Interfaces and Signal-Level Behavior

- Control side typically exposes enable, arm, waveform-select, pulse-length, repetition-interval, and code-table programming registers.
- Data side may output discrete waveform samples, phase increments, or event markers that tell a downstream numerically controlled oscillator when to start and stop.
- Status outputs usually include busy, shot_done, underrun, and sequence_counter indications so a supervisor can coordinate receive blanking windows.
- Optional sync outputs provide a precisely timed trigger to timestamp the transmit epoch for later range or navigation fusion.

## Parameters and Configuration Knobs

- Sample width and phase accumulator width if the module directly synthesizes digitally sampled pings.
- Maximum pulse duration, code length, chirp slope range, and programmable inter-ping interval.
- Support for CW, LFM chirp, Barker-like code, or table-driven arbitrary burst modes.
- Queue depth for preloaded shot descriptors when the platform must schedule multiple pings ahead of time.

## Internal Architecture and Dataflow

A typical implementation contains a shot scheduler, waveform-state machine, optional phase or frequency sweep engine, and a descriptor or code memory. When armed, the scheduler waits for the programmed epoch, asserts a transmit-active window, and advances through waveform segments while keeping a deterministic sample count so matched-filter reference generation remains aligned with the emitted pulse definition.

## Clocking, Reset, and Timing Assumptions

This block normally runs in the system sample clock or a closely related waveform clock domain. Reset should force the transmitter idle and clear any partially issued shot descriptor. If the design spans separate control and waveform domains, descriptor handoff needs explicit CDC protection so a half-updated pulse plan is never transmitted.

## Latency, Throughput, and Resource Considerations

Resource cost is modest for simple gated-tone generation and increases when arbitrary code memories, chirp accumulators, or queued descriptors are supported. Throughput must sustain one waveform decision per emitted sample with no bubbles once a shot begins, because any discontinuity directly degrades transmit fidelity and downstream matched-filter gain.

## Verification Strategy

- Check exact pulse length, start time, and inter-ping interval across minimum and maximum register settings.
- Verify chirp or code progression against a golden waveform model sample by sample.
- Stress abort, retrigger, and back-to-back descriptor cases to ensure no partial or duplicated shots occur.
- Confirm sync markers and busy windows align with the first and last emitted sample under all supported modes.

## Integration Notes and Dependencies

Ping Generator usually feeds a waveform formatter, DAC path, or transmit beamforming chain and must be integrated with receive blanking control so the front end is protected during emission. At the system level it also interacts with timestamping logic, calibration storage, and safety policies that cap duty cycle or average acoustic output.

## Edge Cases, Failure Modes, and Design Risks

- Descriptor updates too close to launch can produce the wrong waveform unless control writes are cleanly double-buffered.
- Ignoring power or duty-cycle limits can overheat the transducer or violate platform acoustic constraints.
- A mismatch between emitted waveform and receiver matched-filter reference will quietly reduce detection performance.

## Related Modules In This Domain

- matched_filter
- hydrophone_frontend_interface
- sonar_data_framer
- delay_and_sum_beamformer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Ping Generator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
