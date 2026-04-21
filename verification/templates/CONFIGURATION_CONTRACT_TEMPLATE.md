# Module Family Configuration Contract Template

## Module Family

- Family name:
- Domain:
- Stable core name:
- Public wrapper names:

## Purpose

Describe the problem this module family solves and why multiple interface profiles or observability options are needed.

## Family Architecture

Document the split between:

- stable core behavior
- interface wrappers
- optional packages or interfaces

Call out which files are expected to live in `rtl/` once implementation starts.

## Supported Public Profiles

Create a table with:

| Profile | Intended use | Public port style | Notes |
| --- | --- | --- | --- |

## Shared Semantic Contract

List the rules that must hold across every public profile in the family. Examples:

- ordering rules
- reset behavior
- backpressure rules
- error behavior
- latency guarantees or bounds

## Parameters

Create a table with:

| Parameter | Type | Legal range | Default | Affects ports? | Meaning |
| --- | --- | --- | --- | --- | --- |

Split parameters into:

- structural
- interface-profile
- observability
- timing or latency

## Port Visibility Policy

Document which ports belong to which profile. When possible, use wrapper selection instead of a single superset module with conditionally meaningful ports.

## Illegal Or Unsupported Combinations

Document combinations that must be rejected clearly, such as:

- depth not supported for a given algorithm
- sideband widths required only in packet mode
- latency option incompatible with another mode

## Reset And Clocking Assumptions

State:

- reset style
- clock-domain assumptions
- CDC or multicycle assumptions
- startup convergence expectations

## Verification Impact

List which configuration axes must be swept during verification and which ones only need spot checks.

## Integration Notes

Call out wrapper choice, expected packing of payload or sidebands, and any tool-flow caveats.
