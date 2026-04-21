# RISC-V Core Wrapper

## Overview

RISC-V Core Wrapper packages a processor core with the surrounding interfaces, resets, memory links, interrupt paths, and optional feature gates required for SoC integration. It provides the system-level harness around the CPU implementation.

## Domain Context

A RISC-V core wrapper is the integration shell that turns a bare processor core into a system-ready component with clocks, resets, interrupts, memory ports, debug hooks, and platform policy. In this domain it is the architectural boundary between the ISA-visible CPU and the rest of the SoC fabric.

## Problem Solved

A core alone does not define how it boots, handles interrupts, interacts with buses, or exposes debug and performance features. A dedicated wrapper makes those integration choices explicit and stable for software and hardware teams.

## Typical Use Cases

- Integrating a RISC-V CPU into an SoC with standard memory and interrupt infrastructure.
- Adapting one core implementation to several platform configurations.
- Coordinating boot, debug, reset, and power-up sequencing around the CPU.
- Providing a clean software-visible CPU boundary for accelerator-coupled systems.

## Interfaces and Signal-Level Behavior

- Inputs include clocks, resets, interrupt lines, memory or cache interfaces, and debug or halt controls.
- Outputs provide instruction and data bus traffic, exception or status information, and debug-visible CPU state interfaces as configured.
- Control interfaces configure boot vector, feature enables, and optional privilege or platform-specific behavior gates.
- Status signals may expose core_halted, reset_done, and fatal_fault or unsupported_feature indications.

## Parameters and Configuration Knobs

- Supported privilege profile and extension set exposed by the integration.
- Instruction and data interface style, such as cached, uncached, or tightly coupled memories.
- Boot-vector configurability and reset policy.
- Optional debug, performance counter, and low-power integration support.

## Internal Architecture and Dataflow

The wrapper typically contains bus adapters, reset and clock crossing logic, interrupt routing, boot-vector handling, and optional feature muxing around the core. The key contract is which architectural features are presented to software and how they are wired into platform-specific peripherals, because this wrapper effectively defines the CPU personality of the SoC.

## Clocking, Reset, and Timing Assumptions

The wrapper assumes the underlying core follows the claimed ISA and privilege semantics and that external memories and interrupt sources meet the timing and protocol expectations. Reset behavior should clearly define when fetch begins and what state is architecturally valid after release. If some ISA features are fuse- or configuration-dependent, their discovery model should be explicit.

## Latency, Throughput, and Resource Considerations

Performance is influenced by memory-path latency, wrapper arbitration, and cache or tightly coupled memory choices more than by wrapper logic itself. The main tradeoff is between flexible platform integration and keeping the CPU path lean enough not to bottleneck the core.

## Verification Strategy

- Check boot, reset, and interrupt sequencing against platform requirements.
- Verify bus and memory semantics using representative software and transaction-level references.
- Stress debug halt, resume, and exception paths when integrated with other subsystem traffic.
- Run ISA or platform compliance tests on the wrapped core rather than the bare core alone.

## Integration Notes and Dependencies

RISC-V Core Wrapper ties together caches, CLINT, PLIC, Debug Module, Boot ROM, and TCM or fabric interfaces. It should align with software-visible memory maps and privilege expectations so firmware sees a coherent processor subsystem.

## Edge Cases, Failure Modes, and Design Risks

- A correct core can still misbehave systemically if reset, interrupt, or boot-vector wiring is wrong.
- Feature gating that is not reflected in software discovery can create subtle platform incompatibilities.
- Wrapper-added latency on memory or interrupt paths can degrade real software behavior in ways bare-core benchmarks do not reveal.

## Related Modules In This Domain

- debug_module
- boot_rom
- clint_block
- plic_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the RISC-V Core Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
