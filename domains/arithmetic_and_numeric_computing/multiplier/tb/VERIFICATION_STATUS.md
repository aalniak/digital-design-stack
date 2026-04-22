# Multiplier Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_multiplier_verification.ps1`

## Verified Behaviors

- unsigned full-width multiplication
- unsigned low-slice export with discarded-bit reporting
- unsigned high-slice export with discarded-bit reporting
- signed full-width multiplication
- exact selected-slice and discarded-bit behavior for the formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no rounded narrowing policy yet
- no pipelined DSP-oriented variant yet
- no mixed signedness per operand yet
