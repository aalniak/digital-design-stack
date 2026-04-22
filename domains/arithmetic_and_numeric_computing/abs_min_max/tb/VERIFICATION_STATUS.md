# Abs Min Max Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_abs_min_max_verification.ps1`

## Verified Behaviors

- signed min and max ordering across negative and positive operands
- equality and less-than flag behavior
- saturating absolute value on the signed most-negative input
- unsigned compare-select behavior with abs passthrough
- non-saturating most-negative abs behavior when `SATURATE_ABS = 0`
- exact compare and abs behavior for the formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no dual-abs or magnitude-compare variant yet
- no pipelined implementation yet
- no randomized wide-width regression yet
