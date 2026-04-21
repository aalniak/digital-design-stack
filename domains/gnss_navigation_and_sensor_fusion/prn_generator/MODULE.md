# PRN Generator

## Overview

PRN Generator emits the code sequences associated with supported GNSS satellites and signal families so downstream correlators can compare local replicas against the incoming waveform. It is the digital reference source for code-domain synchronization.

## Domain Context

The PRN generator sits at the front of the GNSS baseband tracking chain. It produces the deterministic spreading codes used by acquisition and tracking loops to align the locally generated satellite replica with the received signal.

## Problem Solved

GNSS acquisition and tracking rely on exact code replicas with correct phase progression and satellite selection. If code generation is approximate, mistimed, or inconsistently parameterized across consumers, correlation peaks weaken and the rest of the receiver becomes harder to tune or trust.

## Typical Use Cases

- Generating C/A-like spreading codes for acquisition searches.
- Supplying continuously advancing local code to DLL tracking loops.
- Supporting multi-constellation or multi-signal experiments with selectable PRN families.
- Providing code-phase reference streams for validation and simulation harnesses.

## Interfaces and Signal-Level Behavior

- Control inputs typically select constellation, PRN ID, code phase, chip rate mode, and reset or hold behavior.
- Outputs provide code chips or wider code words at a rate aligned to the correlator or numerically controlled code engine.
- Status signals may indicate valid PRN selection, epoch rollover, and code boundary markers.
- Optional debug outputs expose code phase counters and early or late tap variants for loop debugging.

## Parameters and Configuration Knobs

- Supported constellations and signal families.
- Code length, chip representation, and output parallelism.
- Initial code-phase resolution and whether fractional chip stepping is supported externally or internally.
- Number of simultaneous PRN instances generated in parallel.

## Internal Architecture and Dataflow

A typical implementation uses LFSR or table-driven code generation with phase counters and signal-family-specific tap definitions. The important contract is that the generated code sequence and epoch markers match the published signal definition exactly, because every downstream correlator assumes the local replica is canonical.

## Clocking, Reset, and Timing Assumptions

The generator usually runs from a baseband clock and either advances one chip per tick or under control of a code NCO. Reset must place the phase at a documented origin. If multiple domains consume the output, code phase and epoch events should be distributed without ambiguity.

## Latency, Throughput, and Resource Considerations

Logic cost is low for a small number of channels and rises modestly with many parallel satellites or signal variants. Throughput must sustain the correlator update rate, and deterministic code timing matters more than raw combinational speed.

## Verification Strategy

- Compare generated code sequences against a trusted GNSS reference for each supported PRN and signal family.
- Check phase reset, rollover, and epoch markers at exact chip boundaries.
- Verify multiple simultaneous PRN instances do not interfere with one another.
- Stress control updates to ensure PRN changes occur only on documented safe boundaries.

## Integration Notes and Dependencies

PRN Generator feeds Acquisition Correlator Bank and Code Tracking DLL while interacting with host-side channel assignment logic. It should also align with any simulation or test-vector tooling so the same code definitions are used across verification and live processing.

## Edge Cases, Failure Modes, and Design Risks

- An incorrect tap definition or phase origin can silently weaken every correlation result.
- Changing PRN selection mid-epoch without a clean boundary can break tracking loops.
- If early and late tap relationships are ambiguous, loop tuning becomes error-prone.

## Related Modules In This Domain

- acquisition_correlator_bank
- code_tracking_dll
- nav_bit_synchronizer
- pseudorange_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PRN Generator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
