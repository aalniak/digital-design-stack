# Pilot Inserter or Extractor

## Overview

The pilot inserter or extractor manages reference symbols used for channel estimation, synchronization, or tracking by either placing them into a waveform structure or recovering them from it. It is a waveform-structure block that serves both TX and RX paths.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Pilot symbols carry calibration and tracking information, but their placement and interpretation vary by waveform. Hard-coding those locations into every neighboring module creates brittle systems. This module centralizes pilot handling with a documented map and timing contract.

## Typical Use Cases

- Inserting pilot symbols into OFDM or framed waveforms on transmit.
- Extracting pilot-bearing resources for channel or frequency estimation on receive.
- Providing reusable pilot-structure logic across several waveform profiles.

## Interfaces and Signal-Level Behavior

- Data side exchanges payload-bearing symbols or subcarriers.
- Pilot side accepts or emits pilot symbols, pilot indices, and optional quality metadata.
- Control side configures pilot pattern, frame profile, and TX versus RX operating mode.

## Parameters and Configuration Knobs

- Pilot-grid definition, symbol precision, profile count, and active-resource geometry.
- TX versus RX mode, pilot sequence generation or expected-reference handling, and runtime profile selection.
- Metadata widths for pilot indices, validity, and confidence outputs.

## Internal Architecture and Dataflow

On transmit, the block merges pilot symbols into the appropriate waveform positions while preserving the payload map. On receive, it selects those same positions and emits pilot observations for estimators or tracking loops. The documentation should state whether pilot positions are represented as absolute indices, frame-relative positions, or structured grids, and whether data resources around pilots are compacted or passed through sparsely.

## Clocking, Reset, and Timing Assumptions

The pilot map must match the waveform profile used by the modem and estimator exactly. Reset should clear any frame-relative pilot counters or state before a new frame begins.

## Latency, Throughput, and Resource Considerations

The arithmetic cost is small, but the indexing and buffering logic must keep up with symbol throughput while preserving a clean mapping contract. Resource use depends on profile flexibility and whether sparse compaction is supported.

## Verification Strategy

- Compare inserted and extracted pilot positions against a waveform reference for several profiles.
- Check frame-boundary handling, pilot-sequence ordering, and TX or RX mode behavior.
- Verify interactions with null carriers and data compaction if supported.

## Integration Notes and Dependencies

This block typically sits between the modem core and channel-estimation or mapping logic, so pilot indexing and profile semantics should be documented with those neighbors. Integrators should also note whether pilot values are generated internally or supplied externally.

## Edge Cases, Failure Modes, and Design Risks

- A pilot-map mismatch can destabilize estimation while leaving the payload path apparently healthy.
- Sparse compaction conventions that are not explicit can reorder pilot observations silently.
- Runtime profile changes without frame synchronization may create mixed pilot grids.

## Related Modules In This Domain

- ofdm_modem_core
- channel_estimator
- carrier_recovery

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pilot Inserter or Extractor module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
