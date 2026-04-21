# Correlator Bank

## Overview

The correlator bank compares the received signal against several candidate reference sequences in parallel, producing detection or synchronization metrics across codes, pilots, or hypotheses. It is a search-oriented front-end block for acquisition and detection.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Receivers and spread-spectrum systems often need to test many possible sequences or alignments before they know which one is present. A single correlator is not enough for that search space, so this module provides the reusable multi-hypothesis correlation engine.

## Typical Use Cases

- Detecting synchronization sequences or spreading codes.
- Searching several candidate pilots or preambles during acquisition.
- Providing reusable multi-reference detection in SDR systems.

## Interfaces and Signal-Level Behavior

- Input side accepts complex or real baseband samples.
- Reference side loads or selects several candidate sequences or templates.
- Output side emits correlation metrics, peak locations, and optional winning-index metadata.

## Parameters and Configuration Knobs

- Number of references, sequence length, sample precision, and output metric width.
- Complex versus real mode, sliding versus block correlation mode, and normalization policy.
- Runtime reference-bank switching and maximum-output candidate count.

## Internal Architecture and Dataflow

The bank replicates or time-multiplexes correlation logic across several references, accumulating match scores for each hypothesis and reporting peaks or scores as configured. The contract should define whether outputs are raw correlation sums, magnitudes, normalized scores, or peak events, and how reference indices map to physical hypotheses.

## Clocking, Reset, and Timing Assumptions

Reference sequences and sample timing must share the documented sample rate and phase convention. Reset should clear all accumulation state and peak trackers before a new search interval.

## Latency, Throughput, and Resource Considerations

Correlator banks can be compute intensive because cost scales with sequence length and hypothesis count. Resource use depends strongly on whether the bank is fully parallel or time multiplexed.

## Verification Strategy

- Compare scores and winning indices against a reference implementation for several sequences and timing offsets.
- Check normalization, peak reporting, and reference-bank switching.
- Verify reset and search-window boundary handling.

## Integration Notes and Dependencies

This block often feeds acquisition, CFO estimation, or frame sync logic, so its score semantics and index mapping should be documented with those consumers. Integrators should also note whether correlations are coherent, noncoherent, or mixed.

## Edge Cases, Failure Modes, and Design Risks

- Reference-index mismatches can make acquisition appear to lock to the wrong hypothesis.
- Sliding-window alignment errors may only appear on nonzero offsets.
- If normalized and raw scores are confused, downstream thresholds will not transfer correctly.

## Related Modules In This Domain

- cfo_estimator
- carrier_recovery
- framer_deframer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Correlator Bank module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
