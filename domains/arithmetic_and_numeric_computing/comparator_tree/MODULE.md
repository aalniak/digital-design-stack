# Comparator Tree

## Overview

comparator_tree reduces many candidate values to one selected result such as global minimum, maximum, or winner index. It is the scalable selection primitive for reduction-heavy arithmetic pipelines.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

Selecting an extremum from many candidates becomes timing-sensitive and error-prone as fan-in grows. comparator_tree provides a staged structure with explicit tie behavior and latency.

## Typical Use Cases

- Find argmax in post-processing pipelines.
- Reduce many distance or score candidates to a winner.
- Build winner-take-all or tournament-style selection logic.

## Interfaces and Signal-Level Behavior

- Inputs are an array or vector of values, often with associated tags or indices.
- Outputs may include winner value, winner index, and optional compare flags.
- Pipelined versions use fixed latency and may expose valid timing.

## Parameters and Configuration Knobs

- NUM_INPUTS defines fan-in.
- DATA_WIDTH sets candidate width.
- SIGNED_MODE controls interpretation.
- RETURN_INDEX_EN exposes winner index.
- PIPELINE_LEVELS inserts registers between tree stages.

## Internal Architecture and Dataflow

The module is a hierarchy of compare-select stages. At each level, value and associated tag move together so final outputs remain aligned. Tie-breaking policy is as important as the compare itself.

## Numeric Format, Clocking, and Timing Assumptions

Input order matters when equal values are resolved by first occurrence or lowest index. If masked or invalid entries are supported, that policy must be explicit.

## Latency, Throughput, and Resource Considerations

Tree structure scales better than a flat chain, but wide values and high fan-in can still need pipelining. Resource cost rises with compare count and carried metadata.

## Verification Strategy

- Check deterministic tie-breaking under equal values.
- Verify index and value stay aligned through the tree.
- Exercise signed and unsigned modes separately.
- Compare pipelined output against a software reduction model.

## Integration Notes and Dependencies

comparator_tree is common in pooling, scoring, and scheduling support logic. Shared tie-breaking conventions help higher-level behavior stay deterministic.

## Edge Cases, Failure Modes, and Design Risks

- Tie-breaking left implicit leads to unpredictable system behavior.
- Pipelining can desynchronize value and index if tags are not forwarded carefully.
- Wide compare trees can surprise timing closure late in a project.

## Related Modules In This Domain

- abs_min_max
- popcount_unit
- leading_zero_counter
- mac_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Comparator Tree module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
