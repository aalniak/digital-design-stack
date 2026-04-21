# Round Robin Arbiter Implementation Status

## Current Status

`round_robin_arbiter` is implemented and verified as the reusable fairness-oriented requester selector for shared resources.

The current implementation supports:

- configurable requester count through `NUM_REQUESTERS`
- masked arbitration
- pointer advancement on explicit `advance`
- one-hot and encoded winner outputs

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- directed rotating grant simulation under continuous requests
- directed pointer-hold simulation when `advance = 0`
- directed masking and wraparound simulation
- Yosys synthesis sanity
- SymbiYosys formal proof of one-hot and grant-subset invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_round_robin_arbiter_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- Pointer movement happens only on explicit `advance`.
- Fairness is preserved across accepted grants, not across merely observed requests.
- The current baseline has no hold or park mode.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- hold-until-end ownership semantics
- idle park mode
- hierarchical selection for very wide requester counts
- automated parameter sweeps across larger requester counts

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Expand verification breadth
   - add parameter sweeps over requester count
   - add stronger formal properties around pointer advancement

2. Grow the family shape
   - add hold semantics
   - add idle park and alternate fairness modes

3. Improve integration visibility
   - add optional pointer-state visibility for debug and performance analysis
