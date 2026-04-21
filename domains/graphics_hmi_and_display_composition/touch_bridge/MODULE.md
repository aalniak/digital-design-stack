# Touch Bridge

## Overview

Touch Bridge receives touch or pointer input data, normalizes coordinates and event semantics, and forwards them to local UI logic or software-visible interfaces. It provides the input integration layer for touch-enabled HMIs.

## Domain Context

A touch bridge connects input-sensing data from a touch controller or local sensor path into the HMI graphics and interaction stack. In this domain it is the control-plane counterpart to display composition, translating touch events into normalized UI interaction signals.

## Problem Solved

Touch controllers and UI software often speak different event and coordinate conventions. A dedicated bridge centralizes translation, debouncing, and event packaging so the rest of the interface stack sees stable input semantics.

## Typical Use Cases

- Normalizing touch-controller outputs for embedded UI software.
- Generating pointer events for cursor or focus overlays.
- Bridging capacitive touch events into an on-chip HMI subsystem.
- Supporting touch-aware menus, soft buttons, and gesture-capable control panels.

## Interfaces and Signal-Level Behavior

- Inputs include raw touch coordinates, contact status, optional gesture or pressure metadata, and synchronization or interrupt signals from the touch source.
- Outputs provide normalized touch events, coordinate data, and event-valid or queue status.
- Control interfaces configure coordinate scaling, orientation transforms, debounce, and multi-touch policy.
- Status signals may expose touch_overrun, source_invalid, and calibration_active indications.

## Parameters and Configuration Knobs

- Coordinate width and screen-size mapping.
- Single-touch versus multitouch support.
- Debounce and event-queue depth.
- Rotation or mirror transform options.

## Internal Architecture and Dataflow

The bridge typically contains coordinate transformation, event filtering or debouncing, packaging into local event records, and optional interrupt generation. The key contract is whether the output is a raw sampled touch stream or higher-level press, move, and release events, because UI software depends on that abstraction level.

## Clocking, Reset, and Timing Assumptions

The block assumes the touch source is calibrated or that calibration parameters are supplied consistently. Reset clears pending events and input history. If coordinate transforms are configurable at runtime, their activation boundary should be explicit to avoid mixed-coordinate event streams.

## Latency, Throughput, and Resource Considerations

Input event rates are low compared with display pixel rates, so clarity and determinism matter more than throughput. The main tradeoff is between minimal raw-event latency and enough filtering to suppress noisy or bouncing touch transitions.

## Verification Strategy

- Compare normalized output events against a software touch-processing reference under several orientation and calibration settings.
- Stress bounce, rapid contact changes, and coordinate edge cases.
- Verify queueing and overflow behavior under gesture-like bursts.
- Check integration with cursor or UI focus logic using end-to-end interaction tests.

## Integration Notes and Dependencies

Touch Bridge commonly feeds cursor or focus control, GUI software, and potentially hardware widgets. It should align with display coordinate conventions and any host-side event APIs so input and visual response stay consistent.

## Edge Cases, Failure Modes, and Design Risks

- A coordinate-transform mismatch makes the UI feel broken even when display rendering is correct.
- Overdebouncing can make touch response feel laggy, while underdebouncing creates phantom presses.
- If event abstraction is vague, software and hardware may each think the other is responsible for press or release interpretation.

## Related Modules In This Domain

- cursor_overlay
- ui_layer_mixer
- frame_compositor
- text_overlay

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Touch Bridge module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
