# Matched Filter

## Overview

Matched Filter computes the correlation between incoming acoustic samples and a stored reference waveform. Its output is a time series with compressed peaks at likely echo arrival times, making later detection, tracking, and range extraction significantly more robust.

## Domain Context

In sonar, the matched filter is the primary pulse-compression and detection-preconditioning block for active returns. It correlates received data against the transmitted ping replica or another expected waveform so weak echoes can be concentrated in time and separated from diffuse noise and reverberation.

## Problem Solved

Long coded or chirped pings provide energy gain, but that gain is only realized if the receive chain performs a correctly aligned matched filter. Leaving this to ad hoc software or loosely specified DSP blocks risks coefficient mismatches, phase errors, and latency uncertainty that directly reduce range resolution and sensitivity.

## Typical Use Cases

- Pulse-compressing LFM or phase-coded pings in active imaging or ranging sonar.
- Supporting channelized matched filtering ahead of beamforming or after beamforming, depending on system architecture.
- Generating detection metrics for CFAR-like or threshold-based echo pickers in underwater surveys.
- Providing correlation outputs for synchronization and transmit-reference validation during calibration.

## Interfaces and Signal-Level Behavior

- Input stream is usually complex or signed real receive data with valid markers and optional frame or beam identifiers.
- Reference memory interface loads the transmit replica, often with explicit coefficient bank select or descriptor tagging.
- Outputs may include full correlation samples, magnitude estimates, peak markers, and latency-aligned valid signals.
- Control paths typically configure filter length, decimation after correlation, scaling mode, and window selection.

## Parameters and Configuration Knobs

- Maximum reference length and whether coefficients are real, complex, or conjugated internally.
- Sample width, accumulator width, scaling schedule, and saturation policy.
- Streaming versus block-based operation, including overlap handling for long filters.
- Optional support for multiple banks so the active ping definition can switch without halting reception.

## Internal Architecture and Dataflow

A practical design uses a coefficient store, sliding multiply-accumulate engine or FFT-based correlator, scaling stage, and output formatter. The key architectural contract is that the correlation reference matches the emitted waveform definition exactly, including any phase coding, tapering, and sample-rate assumptions, so the output peak shape remains predictable across test conditions.

## Clocking, Reset, and Timing Assumptions

The filter normally runs in the main receive sample domain and assumes the reference bank is stable for the duration of a correlation interval. If beamformed channels or decimated data are supplied, the reference must be generated at the same effective sample rate. Reset should flush accumulation history to avoid stale energy leaking into the next receive window.

## Latency, Throughput, and Resource Considerations

Long references improve processing gain but increase multiplier demand or transform latency. Designs often trade exact sample-rate correlation for decimated or partitioned implementations to fit FPGA resources. Sustained throughput must match incoming sample rate; backpressure is usually unacceptable on live sonar receive streams.

## Verification Strategy

- Compare impulse response and correlation peak location against a floating-point golden model for each waveform family.
- Verify coefficient-bank switching only occurs on legal boundaries and never mixes references mid-window.
- Inject reverberation-like clutter plus delayed echoes to confirm peak compression and scaling remain numerically stable.
- Check accumulator growth and saturation behavior under worst-case full-scale input conditions.

## Integration Notes and Dependencies

Matched Filter depends on tight coordination with Ping Generator or waveform-reference management so the stored replica truly reflects what was transmitted. It often feeds threshold detectors, target trackers, beamformers, or data framers and should export enough metadata for those stages to interpret correlation lag as physical range or delay.

## Edge Cases, Failure Modes, and Design Risks

- Reference mismatch to the transmit waveform can degrade gain without causing an obvious functional failure.
- Insufficient accumulator width can bury weak returns under numerical distortion after strong reverberation.
- If overlap or window boundaries are mishandled, echoes near block edges may split or shift in time.

## Related Modules In This Domain

- ping_generator
- passive_detector
- reverberation_suppressor
- target_tracker

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Matched Filter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
