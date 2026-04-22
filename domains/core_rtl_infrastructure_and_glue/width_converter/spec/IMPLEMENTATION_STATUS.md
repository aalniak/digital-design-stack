# Width Converter Implementation Status

## Current Status

`width_converter` is implemented and verified as the baseline byte-oriented width-adaptation primitive for the core library.

The current implementation supports:

- direct pass-through when the widths match
- widening from narrow ingress beats into a wider egress beat
- narrowing from wide ingress beats into several narrower egress beats
- byte-valid propagation through `keep`
- packet-boundary propagation through `last`
- same-clock internal busy tracking

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for bypass, widening, narrowing, partial final groups, and stall behavior
- Yosys synthesis sanity
- SymbiYosys lightweight formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_width_converter_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The module is byte-oriented rather than bit-oriented.
- Lane ordering is low-byte-first.
- The first reusable baseline favors correctness and explicit packet behavior over maximum ratio-boundary throughput.
- Narrowing assumes low-byte-contiguous `keep` for partial words.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- bubble-free adaptation across ratio boundaries
- malformed keep-pattern detection and reporting
- richer sideband families beyond `last`
- broader randomized and sequential formal proofs across many ratios

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Improve throughput
   - add output staging and overlap so ratio boundaries do not force a bubble
   - consider wrapper variants for throughput-first versus simplicity-first use cases

2. Strengthen semantics
   - detect or constrain malformed partial-word keep patterns
   - define a stronger contract for packet-boundary behavior under non-natural widths

3. Expand verification breadth
   - add ratio sweeps across more width combinations
   - add deeper formal checks for narrowing and widening state evolution
