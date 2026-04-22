# Divider Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_divider_verification.ps1`

## Verified Behaviors

- exact unsigned quotient and remainder behavior
- exact signed quotient and remainder behavior under truncation-toward-zero semantics
- divide-by-zero quotient and remainder policy
- signed `SIGNED_MIN / -1` overflow saturation behavior
- remainder suppression when `RETURN_REMAINDER_EN = 0`
- exact documented policy behavior for all input combinations in the formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no iterative or pipelined implementation yet
- no fixed-point scaling mode yet
- no alternate signed remainder convention families yet
