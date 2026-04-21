# Pulse Capture

## Overview

pulse_capture measures or timestamps incoming pulse events such as edge times, widths, or periods relative to a local clock. It is the generic edge-measurement primitive for external timing signals.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

External pulses are often asynchronous, bursty, and measurement-sensitive. pulse_capture turns those events into synchronized timestamps or counts without forcing every client to reinvent edge-detect and timing logic.

## Typical Use Cases

- Measure frequency, duty cycle, or pulse width of an external signal.
- Capture timestamps of event edges for software or hardware control.
- Convert simple sensor or encoder pulse activity into local measurement data.

## Interfaces and Signal-Level Behavior

- Inputs usually include the pulse signal, local timebase or counter reference, and reset.
- Outputs may include captured timestamps, measured period or width values, and valid or overflow status.
- Optional controls configure rising, falling, or both-edge capture and filtering.

## Parameters and Configuration Knobs

- COUNTER_WIDTH sizes measurement range.
- EDGE_MODE selects which transitions are captured.
- WIDTH_MEASURE_EN enables high-time or low-time measurement.
- FILTER_EN adds debounce or glitch rejection.
- FIFO_DEPTH sizes buffering for captured events.

## Internal Architecture and Dataflow

A pulse-capture block typically synchronizes or conditions the external signal, detects edges, and latches a local counter or computes delta times between edges. The key contract issue is capture uncertainty due to synchronization and local clock resolution.

## Clocking, Reset, and Timing Assumptions

External pulse signals may be asynchronous and noisy. The module should document whether the output is a raw sampled timestamp, a filtered event, or an averaged measurement. Reset should clear any pending capture history.

## Latency, Throughput, and Resource Considerations

Measurement precision depends on local counter resolution and synchronization strategy rather than on throughput. Buffering helps only when events arrive faster than the host or consumer can drain them.

## Verification Strategy

- Exercise rising, falling, and both-edge modes.
- Inject closely spaced pulses near the local clock period limit.
- Check filtering and debounce if supported.
- Compare measured width or period against a reference timing model.

## Integration Notes and Dependencies

pulse_capture commonly pairs with timers, counters, GPIO, and control loops. It is especially useful when software wants measured results but should not handle raw asynchronous edge timing itself.

## Edge Cases, Failure Modes, and Design Risks

- Synchronization delay and resolution limits must be visible or measurements will be over-trusted.
- Glitch filtering can hide legitimate narrow pulses if misconfigured.
- Buffered capture paths can overflow under bursty input unless status is clear.

## Related Modules In This Domain

- timer_block
- free_running_counter
- gpio_bank
- quadrature_decoder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pulse Capture module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
