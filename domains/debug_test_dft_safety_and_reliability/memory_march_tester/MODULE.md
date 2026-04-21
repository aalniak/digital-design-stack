# Memory March Tester

## Overview

Memory March Tester executes march-style memory test sequences over a targeted memory address space and reports detected mismatches or fault indications. It provides a reusable algorithm engine for memory structural validation.

## Domain Context

A memory march tester is the algorithmic companion to memory self-test, expressing specific ordered read and write sequences designed to expose memory faults such as stuck-at, transition, and address-coupling issues. In this domain it is the pattern engine behind memory diagnostics.

## Problem Solved

Memory faults often require more than a simple read-write pattern to expose. A dedicated march tester makes the algorithm order, data backgrounds, and address traversal policy explicit so coverage claims remain meaningful.

## Typical Use Cases

- Running March C or related memory algorithms during production test.
- Supporting field diagnostics on critical SRAM or register-file structures.
- Comparing memory macro behavior under different march patterns in validation.
- Providing algorithmic reuse beneath a broader MBIST framework.

## Interfaces and Signal-Level Behavior

- Inputs include start_test, address range, algorithm selection, and target memory connection.
- Outputs provide pass_fail, test_done, and optional fail-address or fail-operation context.
- Control interfaces configure march variant, data background, and ascending or descending traversal choices where supported.
- Status signals may expose bist_active, fail_detected, and unsupported_algorithm conditions.

## Parameters and Configuration Knobs

- Supported march algorithm set.
- Address width and data width support.
- Full-memory versus range-limited execution support.
- Optional retention or pause phases between operations.

## Internal Architecture and Dataflow

The tester generally contains an address walker, operation sequencer, data pattern generator, and compare logic implementing the chosen march schedule. The architectural contract should document which fault classes the supported algorithms are intended to target, because different march families imply different diagnostic expectations.

## Clocking, Reset, and Timing Assumptions

The block assumes exclusive access to the tested memory during execution. Reset aborts the algorithm and returns memory ownership to functional logic in a documented state. If some algorithms depend on memory initialization or retention timing, those conditions should be exposed to the integrator.

## Latency, Throughput, and Resource Considerations

Runtime scales directly with address space and the number of operations per address in the selected march algorithm. Area is modest. The main tradeoff is between stronger algorithmic coverage and longer diagnostic latency.

## Verification Strategy

- Check operation ordering and traversal for each supported march algorithm against a reference specification.
- Inject representative memory fault models where feasible and verify detection.
- Confirm correct range-limited execution and fail-address reporting.
- Verify clean abort and recovery behavior when reset occurs mid-test.

## Integration Notes and Dependencies

Memory March Tester is often embedded inside MBIST Controller or used as its algorithm engine. It should align with target memory wrapper semantics and with system expectations around destructive versus nondestructive test behavior.

## Edge Cases, Failure Modes, and Design Risks

- Algorithm names like March C can be used loosely; the exact sequence implemented must be documented.
- Some tests are destructive, and that fact must be clear to field-diagnostic users.
- If memory ownership is not isolated correctly, the march test can interfere with live system data.

## Related Modules In This Domain

- mbist_controller
- ecc_scrubber
- error_logger
- safe_state_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Memory March Tester module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
