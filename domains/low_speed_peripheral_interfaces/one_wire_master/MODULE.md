# One Wire Master

## Overview

one_wire_master implements the host-side timing and command behavior for a 1-Wire style shared serial line, including reset, presence detect, bit-level transactions, and optional ROM or device command flows. It is the narrow but timing-sensitive control primitive for simple one-line peripherals.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

1-Wire is electrically and temporally constrained enough that software bit-banging is often fragile. one_wire_master captures the line timing and transaction sequencing in one reusable block.

## Typical Use Cases

- Communicate with simple sensors or identification devices on a 1-Wire bus.
- Perform device discovery or presence detection under hardware timing control.
- Offload microsecond-level serial timing from software.

## Interfaces and Signal-Level Behavior

- Bus-facing signals usually include the single data line with drive-enable control.
- Host-facing controls include reset or presence-detect request, bit or byte transfer request, and command sequencing if supported.
- Status often reports busy, presence detected, transfer complete, and timeout or line-fault conditions.

## Parameters and Configuration Knobs

- TIMING_PROFILE selects the supported 1-Wire timing set.
- DISCOVERY_EN enables hardware support for search or ROM-command flows if provided.
- BYTE_MODE_EN allows byte-level host transfers.
- STRONG_PULLUP_HOOK_EN exposes a hook for devices that need it.
- TIMEOUT_EN adds stuck-line detection.

## Internal Architecture and Dataflow

A 1-Wire master usually contains a carefully timed bit engine, presence-detect logic, and optional byte pack-unpack support. The main contract question is how much protocol sequencing remains software-driven versus being automated in hardware.

## Clocking, Reset, and Timing Assumptions

Line electrical behavior often depends on external pull-up and pad control. Reset should release the line cleanly. If discovery or ROM-level features are supported, their boundaries should be explicit because 1-Wire complexity rises quickly beyond raw bit transfers.

## Latency, Throughput, and Resource Considerations

Bandwidth is very low, so correctness of timing is far more important than throughput. Hardware cost is small but the timing engine must be deterministic.

## Verification Strategy

- Check reset and presence-detect sequences.
- Exercise read and write slot timing across the supported profile.
- Verify byte or command sequencing if supported.
- Inject absent-device and stuck-line conditions.

## Integration Notes and Dependencies

one_wire_master is usually software-controlled through a CSR interface and may pair with simple interrupts or status polling. It is most valuable when it clearly documents what the host must still do in software.

## Edge Cases, Failure Modes, and Design Risks

- Microsecond-scale timing details are easy to get almost right and still fail on hardware.
- Line ownership and pull-up assumptions must be explicit.
- Feature creep into device-discovery flows can expand scope rapidly if not contained.

## Related Modules In This Domain

- gpio_bank
- pulse_capture
- timer_block
- interrupt_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the One Wire Master module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
