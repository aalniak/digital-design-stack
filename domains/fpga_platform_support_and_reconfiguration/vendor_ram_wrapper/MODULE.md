# Vendor RAM Wrapper

## Overview

Vendor RAM Wrapper encapsulates FPGA-specific memory primitives behind a normalized local memory interface and parameter set. It provides a reusable abstraction over vendor memory resources.

## Domain Context

Vendor RAM wrappers abstract the many parameter and port-shape differences across FPGA block RAM, distributed RAM, and UltraRAM-style primitives. In this domain they are the portability and integration layer around memory macros used throughout the design.

## Problem Solved

Memory primitive instantiation details vary across device families and tool versions, making direct use brittle and repetitive. A dedicated wrapper localizes those differences and clarifies what semantics the rest of the design may depend on.

## Typical Use Cases

- Instantiating block RAM or UltraRAM behind a consistent project-local interface.
- Supporting portable synthesis across several FPGA families.
- Packaging initialization and reset behavior for reusable subsystem memories.
- Hiding vendor-specific enable, byte-write, and output-register quirks from generic logic.

## Interfaces and Signal-Level Behavior

- Inputs include read and write addresses, data, enables, write strobes, and optional clock or reset lines.
- Outputs provide read data and status or fault signals if parity or ECC is supported.
- Control interfaces configure mode such as simple dual-port or true dual-port and optional initialization files.
- Status signals may expose init_loaded or primitive_error conditions where supported.

## Parameters and Configuration Knobs

- Memory depth, width, and port mode.
- Read-during-write behavior and output register mode.
- Initialization file or reset-content policy.
- Target primitive family or macro selection.

## Internal Architecture and Dataflow

The wrapper usually instantiates one or more vendor RAM macros and adapts their control and data semantics into a normalized local contract. The key contract is what behavior the wrapper guarantees for read-during-write, reset, and initialization, because those details differ substantially across primitives.

## Clocking, Reset, and Timing Assumptions

The block assumes the chosen primitive family supports the requested configuration legally. Reset behavior should state clearly whether contents are preserved, undefined, or initialized. If several primitives are used under one wrapper, any semantic differences should be normalized or documented, not hidden.

## Latency, Throughput, and Resource Considerations

Area and timing depend mostly on the underlying primitive choice. The wrapper itself should add minimal overhead. The important tradeoff is between portability and exposing enough primitive-specific capability to achieve good density or timing.

## Verification Strategy

- Verify read, write, and port-conflict behavior against the intended wrapper contract.
- Check initialization and reset-content semantics on supported families.
- Stress read-during-write corner cases.
- Run synthesis or implementation checks for each targeted primitive configuration.

## Integration Notes and Dependencies

Vendor RAM Wrapper is used widely across caches, FIFOs, scratchpads, and calibration buffers. It should serve as the single project-local definition of memory macro behavior so subsystem authors are not forced to learn every vendor primitive quirk.

## Edge Cases, Failure Modes, and Design Risks

- Hiding primitive-specific behavior without true normalization can create portability traps.
- Read-during-write mismatches are especially dangerous because they often appear only in hardware.
- Initialization semantics that differ across families can invalidate startup assumptions across the whole project.

## Related Modules In This Domain

- vendor_dsp_wrapper
- ddr_phy_wrapper
- scratchpad_tcm
- iodelay_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Vendor RAM Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
