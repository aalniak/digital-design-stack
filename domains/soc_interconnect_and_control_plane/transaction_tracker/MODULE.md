# Transaction Tracker

## Overview

transaction_tracker records the identity and progress of in-flight transactions so requests, beats, and responses can be matched correctly under concurrency. It is the bookkeeping primitive that makes multi-outstanding interfaces manageable.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

As soon as a block allows several requests to be outstanding, simple issue order is no longer enough to associate responses and completions correctly. transaction_tracker centralizes that state instead of duplicating fragile bookkeeping in every master or bridge.

## Typical Use Cases

- Track outstanding AXI or bridge transactions by ID or slot.
- Associate split or merged bursts with their original request context.
- Support completion, timeout, or fault accounting for concurrent operations.

## Interfaces and Signal-Level Behavior

- Inputs typically include allocate, update, complete, and cancel events plus request metadata.
- Outputs provide match results, free-slot availability, and optional timeout or status visibility.
- Some variants also expose per-slot fields for debug or control-plane reads.

## Parameters and Configuration Knobs

- NUM_SLOTS sets maximum concurrency.
- TAG_WIDTH sizes request IDs or local tokens.
- TIMEOUT_EN adds age tracking for hung transactions.
- PARTIAL_PROGRESS_EN enables beat-level or child-burst accounting.
- DEBUG_VISIBILITY_EN exposes internal slot state externally.

## Internal Architecture and Dataflow

A transaction tracker is usually a table of active slots keyed by ID, source, or allocation order, plus comparators and status update logic. The important design decision is whether a transaction is tracked only until first response, until full data completion, or until software-visible retirement.

## Clocking, Reset, and Timing Assumptions

Every client of the tracker must agree on what constitutes allocation, update, and completion. Reset should clear all in-flight slots deterministically. If IDs can be reused quickly, the block must document how it avoids aliasing stale responses to new requests.

## Latency, Throughput, and Resource Considerations

Tracker complexity grows with slot count, metadata width, and lookup frequency. It can sit on hot protocol paths when many concurrent responses need association in one cycle.

## Verification Strategy

- Allocate and retire transactions under heavy concurrency.
- Exercise ID reuse and wraparound cases.
- Inject timeout, cancel, and partial-progress events.
- Verify slot free and match behavior against a transaction reference model.

## Integration Notes and Dependencies

transaction_tracker appears under AXI masters, burst splitters and mergers, and bridges that decouple issue from completion. Reusing one well-tested tracker can remove a lot of subtle protocol logic from surrounding modules.

## Edge Cases, Failure Modes, and Design Risks

- ID reuse and stale completion aliasing are major correctness hazards.
- The meaning of completion must be exact or upper layers will observe inconsistent progress.
- Visibility for debug is valuable because bookkeeping bugs are otherwise very hard to root-cause.

## Related Modules In This Domain

- axi4_master
- burst_splitter
- burst_merger
- debug_bridge

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Transaction Tracker module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
