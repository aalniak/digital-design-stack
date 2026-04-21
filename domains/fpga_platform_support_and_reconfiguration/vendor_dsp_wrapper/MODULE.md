# Vendor DSP Wrapper

## Overview

Vendor DSP Wrapper encapsulates FPGA DSP slice resources behind a normalized arithmetic interface and parameter set. It provides reusable access to hard DSP primitives without exposing every vendor-specific control nuance to generic logic.

## Domain Context

Vendor DSP wrappers abstract FPGA DSP slice primitives used for multiply-accumulate, preadd, and arithmetic pipelines. In this domain they package primitive-specific pipeline and mode details into a stable building block for the rest of the design.

## Problem Solved

Directly instantiating DSP slices throughout a codebase makes portability, verification, and timing closure harder. A dedicated wrapper localizes primitive-specific modes and lets subsystem logic depend on a smaller, clearer arithmetic contract.

## Typical Use Cases

- Building portable MAC and multiply pipelines over FPGA DSP resources.
- Packaging preadder or accumulator modes for reusable arithmetic blocks.
- Controlling DSP pipeline stages and latency in one central wrapper.
- Supporting migration across several FPGA families with different DSP primitives.

## Interfaces and Signal-Level Behavior

- Inputs include arithmetic operands, valid or enable controls, and optional accumulate or mode-select signals.
- Outputs provide arithmetic results and aligned valid or ready status as supported.
- Control interfaces configure operation mode, pipeline depth, and rounding or saturation behavior if implemented.
- Status signals may expose mode_invalid or latency-configuration status.

## Parameters and Configuration Knobs

- Operand widths and signedness.
- Supported primitive modes such as multiply, MAC, or preadd plus multiply.
- Pipeline stage configuration.
- Target DSP primitive family.

## Internal Architecture and Dataflow

The wrapper usually instantiates one or more vendor DSP slices and adapts their porting, control, and pipeline conventions into a local contract. The key architectural question is how much of the primitive?s flexibility is preserved versus hidden for portability, because that choice affects both reuse and performance.

## Clocking, Reset, and Timing Assumptions

The block assumes the chosen operand widths and operation mode map legally onto the targeted DSP primitive. Reset and valid behavior should define pipeline flushing clearly. If saturation or rounding is implemented externally rather than by the primitive, that boundary should be explicit.

## Latency, Throughput, and Resource Considerations

Performance is dominated by the underlying DSP slice timing and configured pipeline depth. The wrapper tradeoff is between exposing a rich flexible mode set and keeping the interface simple enough that users know its exact latency and arithmetic semantics.

## Verification Strategy

- Compare arithmetic results and latency against a software reference across all supported modes.
- Check pipeline-valid alignment and reset flushing.
- Verify target-family-specific legal configuration mapping.
- Run post-synthesis or timing-aware checks on representative DSP-heavy chains.

## Integration Notes and Dependencies

Vendor DSP Wrapper underpins many arithmetic-heavy subsystems, from FIRs to matrix engines, and should align with project-wide conventions for numeric width, latency, and valid timing. It also complements Vendor RAM Wrapper as a portability layer over hard macros.

## Edge Cases, Failure Modes, and Design Risks

- A wrapper that claims portability while exposing family-specific quirks can create subtle migration bugs.
- Latency ambiguity is especially harmful when DSP chains are deeply pipelined.
- Rounding and saturation semantics must be explicit or downstream numeric blocks will disagree about result interpretation.

## Related Modules In This Domain

- vendor_ram_wrapper
- matrix_multiply_engine
- conv2d_engine
- fir_filter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Vendor DSP Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
