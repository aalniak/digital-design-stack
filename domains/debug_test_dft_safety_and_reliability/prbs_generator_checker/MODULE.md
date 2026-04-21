# PRBS Generator/Checker

## Overview

PRBS Generator/Checker emits pseudo-random binary sequences and verifies received sequences against the expected pattern to measure link integrity or exercise datapaths. It provides a standardized test pattern source and sink for reliability diagnostics.

## Domain Context

PRBS generation and checking are standard tools for link validation, built-in test, and bit-error monitoring. In this domain they provide a lightweight way to validate datapath integrity or quantify BER without needing application payload awareness.

## Problem Solved

Real traffic can be too structured or too cumbersome for manufacturing and bring-up validation. A dedicated PRBS block gives designers a known reproducible stress pattern and a deterministic way to count mismatches and loss of lock.

## Typical Use Cases

- Exercising high-speed or internal links during bring-up.
- Measuring BER in validation or manufacturing environments.
- Providing lightweight online integrity monitoring of a serial or parallel path.
- Serving as a reusable datapath self-test aid independent of application payloads.

## Interfaces and Signal-Level Behavior

- Inputs include enable, polynomial selection, seed load, and received data for checker mode.
- Outputs provide generated pattern data, lock or sync status, error counts, and mismatch events.
- Control interfaces configure polynomial family, inversion, seed, and lock acquisition policy.
- Status signals may expose loss_of_lock, error_overflow, and generator_active indications.

## Parameters and Configuration Knobs

- Supported PRBS polynomials and sequence lengths.
- Data width and serial versus parallel update mode.
- Error counter width and lock threshold settings.
- Generator-only, checker-only, or dual-mode support.

## Internal Architecture and Dataflow

The block typically includes LFSR-based pattern generation, pattern-aligned comparison, error counting, and optional lock-acquisition state. The key contract is how checker alignment and relock are handled, because BER interpretation depends strongly on whether occasional slips are treated as one error, many errors, or loss of measurement validity.

## Clocking, Reset, and Timing Assumptions

The module assumes both ends share the same polynomial, seed, and bit ordering. Reset clears error counters and checker alignment history. If parallel PRBS is implemented, the exact update and bit-lane mapping should be documented carefully.

## Latency, Throughput, and Resource Considerations

PRBS blocks are compact and can run at high line rates with careful implementation. The main tradeoff is between flexible polynomial support and timing closure on wide or fast datapaths. Error counting and lock status are often more operationally useful than the pattern data itself.

## Verification Strategy

- Check generator sequences against known PRBS references for all supported polynomials.
- Verify checker lock acquisition, loss of lock, and error count behavior under injected errors.
- Stress seed reload and mode switching boundaries.
- Confirm lane ordering and update semantics for parallel datapaths.

## Integration Notes and Dependencies

PRBS Generator/Checker often works alongside Trace Funnel, Bus Monitor, or link-specific wrappers and may be invoked by LBIST-like or board bring-up tooling. It should align with the actual physical or logical link bit ordering to avoid false failure reports.

## Edge Cases, Failure Modes, and Design Risks

- A checker that mishandles bit slips can overstate BER or mask alignment problems.
- Bit-order mismatches are easy to make and often look like complete link failure.
- Using PRBS pass results as proof of application-level correctness can create false confidence if framing layers are never exercised.

## Related Modules In This Domain

- lbist_controller
- bus_monitor
- trace_funnel
- event_recorder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PRBS Generator/Checker module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
