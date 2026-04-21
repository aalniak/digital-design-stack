# JTAG TAP

## Overview

JTAG TAP implements the IEEE-style test access state machine and serial instruction/data scan behavior that mediates external test and debug access. It provides the foundational serial control port for structured test infrastructure.

## Domain Context

The JTAG test access port is the external control and observation gateway for many debug and DFT flows. In this domain it is the root protocol block that sequences boundary scan, scan access, debug attachment, and sometimes device identification.

## Problem Solved

External debug and test need a deterministic control protocol with clear state transitions and instruction decoding. A dedicated TAP block keeps protocol timing, reset behavior, and scan-path selection centralized rather than duplicated in wrappers.

## Typical Use Cases

- Providing board-level test and boundary-scan access.
- Serving as the external entry point for scan or debug infrastructure.
- Exposing device ID and simple test instructions during manufacturing or bring-up.
- Supporting chained-device test environments with predictable scan behavior.

## Interfaces and Signal-Level Behavior

- Inputs are TCK, TMS, TDI, optional TRST, and internal scan chain or register connections.
- Outputs provide TDO, scan-enable style controls, instruction decode, and test-state indications.
- Control interfaces inside the chip typically map TAP instructions to selected data registers or scan chains.
- Status signals may expose current TAP state, instruction register value, and test-reset indication.

## Parameters and Configuration Knobs

- Instruction register width and supported instruction set.
- Synchronous versus asynchronous test reset support.
- Number and type of data registers or chain selectors.
- Optional device-ID and bypass behavior configuration.

## Internal Architecture and Dataflow

A JTAG TAP generally includes the TAP state machine, instruction register, bypass register, data-register muxing, and TDO timing control. The architectural contract should document exactly which instructions are implemented and which internal paths they expose, because downstream debug and test tooling depends on that mapping.

## Clocking, Reset, and Timing Assumptions

The block assumes TCK is an external asynchronous clock relative to functional logic and that CDC boundaries around internal control signals are handled deliberately. Reset should place the TAP in a standards-compliant known state. If security lifecycle limits debug exposure, the instruction set or path access policy should reflect that explicitly.

## Latency, Throughput, and Resource Considerations

Throughput is low by design; protocol correctness and predictable timing dominate. Area is small, though scan-chain muxing can grow with attached infrastructure. The important tradeoff is between broad observability and the security or routing cost of exposing many internal chains.

## Verification Strategy

- Check TAP state transitions exhaustively against the standard state diagram.
- Verify instruction decode, bypass behavior, and TDO timing under all relevant edges.
- Stress asynchronous TRST and test-reset behavior relative to functional clocks.
- Run end-to-end scan-chain selection tests with representative attached data registers.

## Integration Notes and Dependencies

JTAG TAP sits above Boundary Scan Wrapper, Scan Controller, Debug Module access, and sometimes MBIST or LBIST triggers. It should align with lifecycle or fuse policy so manufacturing access does not unintentionally remain fully exposed in production.

## Edge Cases, Failure Modes, and Design Risks

- A single instruction-map mismatch can break all external tooling despite a correct TAP state machine.
- Weak lifecycle gating around JTAG can create a major post-silicon attack surface.
- Poor CDC treatment of TAP-driven internal controls can create rare, hard-to-debug behavior in functional mode.

## Related Modules In This Domain

- boundary_scan_wrapper
- scan_controller
- debug_module
- trace_funnel

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the JTAG TAP module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
