# MBIST Controller

## Overview

MBIST Controller sequences built-in self-test operations over one or more embedded memories and reports pass or fail and optional failing-address information. It provides the dedicated memory-test control plane for production test and in-field diagnostics.

## Domain Context

Memory BIST is the structured self-test path for embedded SRAMs and similar arrays. In this domain it provides controlled march or pattern testing of memory macros independent of normal software execution.

## Problem Solved

Embedded memories often dominate silicon defect exposure, and software-driven memory tests may be too slow or unavailable early in bring-up. A dedicated MBIST controller makes memory test algorithms, macro multiplexing, and reporting explicit.

## Typical Use Cases

- Running march-style memory tests during manufacturing.
- Testing SRAMs before software boot or after repair flows.
- Providing in-system memory health diagnostics in safety-conscious products.
- Coordinating several memory macros under one reusable BIST control structure.

## Interfaces and Signal-Level Behavior

- Inputs include start_test, selected-memory or memory-group controls, and algorithm-selection commands.
- Outputs provide pass_fail, test_done, and optional fail address or syndrome information.
- Control interfaces configure test algorithm, address range, and memory wrapper interaction mode.
- Status signals may expose memory_busy, bist_active, and algorithm_invalid conditions.

## Parameters and Configuration Knobs

- Number of attached memory instances or groups.
- Supported test algorithms such as march variants or pattern sets.
- Address and data width support for each target macro class.
- Optional retention or partial-range test support.

## Internal Architecture and Dataflow

The controller usually generates memory access sequences, expected data patterns, compare results, and reporting state around muxed memory interfaces. The architectural contract should define which memory wrappers are supported and what reporting granularity is available, because memory macros and test expectations vary across products.

## Clocking, Reset, and Timing Assumptions

The block assumes target memories can be isolated from functional access during MBIST. Reset should return all memory interfaces to functional ownership cleanly. If repair or redundancy information influences test interpretation, that relationship should be documented explicitly.

## Latency, Throughput, and Resource Considerations

MBIST latency scales with memory size and chosen algorithm. Area is moderate and mostly control oriented. The important tradeoff is between richer diagnostic coverage and acceptable test time in manufacturing or in-field operation.

## Verification Strategy

- Verify algorithm sequencing and expected pass or fail behavior on representative memory models.
- Inject stuck-at, coupling, and address decoder faults where possible in simulation.
- Check clean handoff between functional and BIST memory access.
- Validate fail-address and status reporting for diagnosability.

## Integration Notes and Dependencies

MBIST Controller interacts with memory wrappers, scan or JTAG access paths, and sometimes safety diagnostics. It should align with actual macro wrapper behavior and any field-service policy about when memory self-test may run.

## Edge Cases, Failure Modes, and Design Risks

- An MBIST pass result is only as good as the selected algorithm coverage; weak defaults can create false confidence.
- Functional-to-BIST ownership mistakes can corrupt live memory contents or hide true faults.
- Macro-specific assumptions that are not documented clearly limit reuse across memory types.

## Related Modules In This Domain

- memory_march_tester
- lbist_controller
- scan_controller
- error_logger

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the MBIST Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
