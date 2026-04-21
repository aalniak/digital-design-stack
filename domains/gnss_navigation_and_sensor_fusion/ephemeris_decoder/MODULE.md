# Ephemeris Decoder

## Overview

Ephemeris Decoder parses synchronized GNSS navigation bits into ephemeris, almanac, clock, and related message fields according to the supported signal format. It extracts the structured navigation content required by position and timing solvers.

## Domain Context

The ephemeris decoder is where tracked navigation data becomes satellite-specific orbital and clock information. In GNSS receivers it transforms a bit stream into the metadata needed to compute satellite positions, clock corrections, and ultimately a navigation solution.

## Problem Solved

Recovering the raw bit stream is not enough; the receiver must also validate framing, parity, subframe structure, and field interpretation. A dedicated decoder centralizes message parsing so the meaning and freshness of satellite navigation data remain explicit and auditable.

## Typical Use Cases

- Decoding satellite ephemeris for position solution generation.
- Extracting time-of-week, clock correction, and health information from navigation data.
- Supporting cold-start initialization and orbit updates as data ages.
- Providing validated message content to a host processor or embedded navigation engine.

## Interfaces and Signal-Level Behavior

- Inputs are synchronized navigation bits or symbols, frame markers, and channel identifiers.
- Outputs provide parsed message fields, validity flags, age indicators, and update events for newly decoded data.
- Control interfaces select signal format, parity policy, and optional host readout behavior.
- Diagnostic outputs may expose frame alignment state, parity failures, and partially decoded word counters.

## Parameters and Configuration Knobs

- Supported GNSS message formats and field sets.
- Bit buffering depth and word or subframe parser granularity.
- Parity or CRC support and error-report detail level.
- Storage capacity for decoded satellite records and history.

## Internal Architecture and Dataflow

The decoder generally contains a frame aligner, word parser, integrity checker, field extractor, and per-satellite state store. The domain contract should clearly separate tentative decoded content from validated data that is safe for navigation use.

## Clocking, Reset, and Timing Assumptions

The decoder assumes navigation-bit synchronization is good enough to deliver correctly framed symbols or at least consistent candidate boundaries. Reset should clear partially decoded words and stale frame state. If data validity depends on age, the freshness rules should be documented explicitly.

## Latency, Throughput, and Resource Considerations

Parsing cost is low, and latency is governed mainly by message structure rather than hardware depth. The main performance concern is robust handling of parity failures and partial subframes without confusing the surrounding navigation logic.

## Verification Strategy

- Replay known navigation message sequences and confirm exact field extraction.
- Inject parity errors, frame slips, and missing bits to validate recovery behavior.
- Verify age and validity flags update correctly when data expires or is replaced.
- Cross-check parsed orbital parameters against a trusted GNSS message decoder.

## Integration Notes and Dependencies

Ephemeris Decoder consumes Nav Bit Synchronizer output and feeds Pseudorange Engine, Disciplined Clock Controller, and any navigation solver or host interface. It should align with system software on how decoded data is versioned, refreshed, and invalidated.

## Edge Cases, Failure Modes, and Design Risks

- Treating tentative or parity-failed data as valid can corrupt the entire navigation solution.
- Message freshness handling that is too loose can let stale ephemeris linger after long outages.
- If signal-format assumptions are implicit, future constellation support becomes error-prone.

## Related Modules In This Domain

- nav_bit_synchronizer
- pseudorange_engine
- disciplined_clock_controller
- kalman_fusion_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Ephemeris Decoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
