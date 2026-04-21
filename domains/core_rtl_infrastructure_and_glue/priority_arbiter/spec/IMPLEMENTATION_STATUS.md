# Priority Arbiter Implementation Status

## Current Status

`priority_arbiter` is implemented and verified as the reusable fixed-priority requester selector for deterministic resource access.

The current implementation supports:

- configurable requester count through `NUM_REQUESTERS`
- configurable priority direction through `LOW_INDEX_HIGH_PRIORITY`
- masked arbitration
- one-hot and encoded winner outputs

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- directed low-index-priority simulation
- directed high-index-priority simulation
- directed masking simulation
- no-request idle simulation
- Yosys synthesis sanity
- SymbiYosys formal proof of one-hot and grant-subset invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_priority_arbiter_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- Arbitration is combinational in this first implementation.
- The priority policy is fixed by index direction rather than a programmable table.
- The encoded winner output is always present.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- hold or lock-until-accept state
- programmable priority maps
- multi-grant modes
- automated parameter sweeps across larger requester counts

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Expand verification breadth
   - add parameter sweeps over requester count
   - add stronger formal properties around encoded-output consistency

2. Grow the family shape
   - add lock or hold semantics
   - add programmable priority maps

3. Improve integration visibility
   - add optional request and mask debug pass-throughs where helpful
