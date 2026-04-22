# Comparator Tree Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_comparator_tree_verification.ps1`

## Verified Behaviors

- signed max reduction with distinct candidates
- deterministic lowest-index tie-breaking under equal winning values
- valid-mask filtering of higher-valued candidates
- all-invalid zeroed output behavior
- unsigned min reduction behavior
- winner-index suppression when `RETURN_INDEX_EN = 0`
- exact winner value, winner index, and `any_valid` behavior for the formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no pipelined stage insertion yet
- no metadata sideband forwarding yet
- no randomized large-fan-in regression yet
