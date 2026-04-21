# Debug Module

## Overview

Debug Module provides standardized halt, resume, register access, and optional memory access services for attached processor cores. It is the processor-side control hub for external debug workflows.

## Domain Context

The debug module is the architectural control point for halting, stepping, and inspecting processors or harts in a RISC-V-style subsystem. In this domain it mediates between external debug transports and privileged internal CPU control.

## Problem Solved

External JTAG or debug transports need a clean, privilege-aware way to stop cores and inspect architectural state. A dedicated debug module centralizes this control rather than coupling tools directly to ad hoc core internals.

## Typical Use Cases

- Halting and single-stepping a CPU during silicon bring-up.
- Reading and writing registers or memory through an external debug link.
- Supporting firmware debugging before higher-level software services exist.
- Providing standardized debug behavior across several wrapped core variants.

## Interfaces and Signal-Level Behavior

- Inputs include external debug requests, transport-layer commands, and core status or acknowledgement signals.
- Outputs provide halt, resume, abstract-command execution, and debug-state reporting toward the processor.
- Control interfaces configure supported abstract commands, hart selection, and access restrictions.
- Status signals may expose halted, busy, command_error, and unavailable_hart conditions.

## Parameters and Configuration Knobs

- Number of supported harts.
- Abstract command support level and data register width.
- Memory-access and system-bus access support.
- Lifecycle or privilege gating of debug features.

## Internal Architecture and Dataflow

The module typically contains hart-control state machines, abstract command machinery, debug registers, and optional system-bus access logic. The critical contract is which operations are supported and under what security or lifecycle conditions, because debug capability is both indispensable in validation and risky in production.

## Clocking, Reset, and Timing Assumptions

The module assumes attached cores implement the required debug hooks and that transport-side protocols deliver valid requests. Reset should define whether debug state survives or clears. If production lifecycle modes restrict or disable debug, those restrictions should be enforced here as well as documented clearly.

## Latency, Throughput, and Resource Considerations

Debug throughput is not usually performance critical, but command latency affects usability during bring-up. Area scales with hart count and feature richness. The important tradeoff is between richer debug power and the resulting exposure or complexity in production silicon.

## Verification Strategy

- Verify halt, resume, and register-access behavior on real core integration scenarios.
- Stress error handling for invalid commands, unavailable harts, and concurrent events such as exceptions.
- Check lifecycle gating and debug disable behavior.
- Run tool-driven debug flows end to end through the intended transport stack.

## Integration Notes and Dependencies

Debug Module works with JTAG or other transports, RISC-V Core Wrapper, and sometimes system-bus access paths. It should align with security policy and software expectations about what state is inspectable under each lifecycle mode.

## Edge Cases, Failure Modes, and Design Risks

- A permissive debug module can become a major post-deployment attack surface.
- Partial or mismatched abstract-command support often causes frustrating tool incompatibility.
- Debug interactions with caches or halted DMA can create system states that are hard to reason about if not documented.

## Related Modules In This Domain

- jtag_tap
- riscv_core_wrapper
- boot_rom
- performance_counter_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Debug Module module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
