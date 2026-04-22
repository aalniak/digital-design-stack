# Saturating Adder Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_saturating_adder_verification.ps1`

## Verified Behaviors

- signed in-range addition without clipping
- signed positive clipping to the configured upper bound
- signed negative clipping to the configured lower bound
- unsigned clipping to the native all-ones maximum
- carry-in increment behavior when enabled
- custom signed bound clipping in both directions
- flag suppression behavior when `FLAG_EN = 0`
- exact clipped-result and clip-flag behavior for the formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no invalid custom-limit ordering detection yet
- no subtract or accumulate variants yet
- no randomized wide-operand regression yet
