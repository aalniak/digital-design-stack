# Complex Multiplier Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_complex_multiplier_verification.ps1`

## Verified Behaviors

- signed complex multiplication without conjugation
- signed complex multiplication with `conjugate_b = 1`
- unsigned complex multiplication on a non-negative example
- exact widened real and imaginary recombination behavior for the formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no reduced-multiplier architecture yet
- no pipelined DSP-oriented variant yet
- no output narrowing or rounding policy yet
