# Stream Mux Implementation Status

## Current Status

`stream_mux` is implemented and verified as the baseline same-clock fan-in primitive for the core library.

The current implementation supports:

- low-index priority arbitration
- round-robin arbitration
- optional packet-hold behavior through `HOLD_UNTIL_LAST`
- optional source tagging through `m_source_id`
- reset-clean held-grant observability through `held_grant_active` and `held_grant_id`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for priority selection, round-robin fairness, packet-hold behavior, and ready routing
- Yosys synthesis sanity
- SymbiYosys lightweight formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_stream_mux_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The baseline module is non-buffered.
- Round-robin fairness is packet-granular when hold mode is enabled.
- The source-tag output is always present, but can be logically disabled.
- The current baseline relies on standard ready-valid source behavior during held packets.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- buffered timing-relief variants
- external grant override or lock modes
- diagnostics for a source dropping valid mid-held-packet
- broader randomized regressions and deeper sequential formal checks

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Improve flow-control resilience
   - add buffered or skid-assisted wrappers for large fan-in timing paths
   - add optional source-contract violation detection in hold mode

2. Expand arbitration support
   - add externally driven or weighted arbitration variants
   - add explicit fairness metrics in verification

3. Expand verification breadth
   - add randomized contention scenarios with longer packet streams
   - add deeper formal checks around round-robin pointer evolution
