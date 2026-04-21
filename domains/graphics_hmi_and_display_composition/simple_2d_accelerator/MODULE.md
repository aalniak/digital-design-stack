# Simple 2D Accelerator

## Overview

Simple 2D Accelerator provides a unified command-driven engine for common 2D operations such as blits, fills, and basic vector drawing. It offers lightweight graphics acceleration for UI and instrumentation applications.

## Domain Context

A simple 2D accelerator groups a handful of practical graphics primitives under one programming and scheduling surface, offering more convenience than isolated blit or fill blocks without the complexity of a GPU. In this domain it is the compact graphics offload engine for embedded HMIs.

## Problem Solved

Many embedded products need a small set of graphics operations offloaded from the CPU, but integrating several independent engines with different command styles is cumbersome. A dedicated 2D accelerator provides one cohesive interface for these tasks.

## Typical Use Cases

- Offloading routine UI redraw operations from a CPU.
- Providing a compact graphics engine for industrial or automotive displays.
- Supporting boot-time and diagnostic graphics without a full GPU stack.
- Bundling several simple 2D primitives behind one driver-facing interface.

## Interfaces and Signal-Level Behavior

- Inputs include command descriptors, optional source image data or addresses, and control or synchronization requests.
- Outputs provide command completion, error reporting, and optional progress or interrupt signals.
- Control interfaces configure supported operation modes, descriptor queues, and target-buffer policy.
- Status signals may expose engine_busy, command_error, and queue_overflow conditions.

## Parameters and Configuration Knobs

- Supported primitive set such as blit, fill, line, and simple copy or color conversion.
- Descriptor queue depth and command format width.
- Pixel format support.
- Optional interrupt-on-completion or fence support.

## Internal Architecture and Dataflow

The accelerator usually fronts one or more primitive engines with a shared descriptor parser, scheduler, and memory interface. The key contract is whether commands are guaranteed to complete in order and whether operations are atomic relative to display scanout or only best effort, because software composition strategies depend on that behavior.

## Clocking, Reset, and Timing Assumptions

The module assumes software supplies well-formed commands and manages buffer ownership according to the documented synchronization model. Reset clears pending commands or marks them invalid according to policy. If some primitives reuse the same memory path, the arbitration and command-interleaving rules should be explicit.

## Latency, Throughput, and Resource Considerations

Performance is bounded mostly by memory bandwidth and command scheduling efficiency rather than arithmetic. The main tradeoff is between a simple reliable command model and richer primitive coverage that can complicate scheduling and validation.

## Verification Strategy

- Run mixed primitive command streams against a software 2D reference.
- Stress queue overflow, invalid command descriptors, and command completion ordering.
- Verify memory behavior when blits and fills target overlapping regions.
- Check synchronization assumptions with live display output or compositor fetch.

## Integration Notes and Dependencies

Simple 2D Accelerator often wraps or coordinates Blitter, Fill, and Line primitives and connects to the frame-buffer memory system. It should align with driver software on command ordering, fencing, and visible-update timing.

## Edge Cases, Failure Modes, and Design Risks

- Command completion semantics that are unclear can lead to race conditions in software redraw logic.
- Bundling many primitives behind one engine increases the chance of shared-resource interactions that isolated tests may miss.
- A 2D accelerator that is not explicit about display synchronization can create persistent UI tearing issues.

## Related Modules In This Domain

- blitter
- rectangle_fill_engine
- line_draw_engine
- frame_compositor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Simple 2D Accelerator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
