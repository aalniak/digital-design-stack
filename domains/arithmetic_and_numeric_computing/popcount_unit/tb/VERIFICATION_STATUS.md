# Popcount Unit Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_popcount_unit_verification.ps1`

## Verified Behaviors

- all-zero input count and flag behavior
- all-one input count and full-flag behavior
- sparse mixed-pattern counting
- alternating-bit pattern counting
- flag suppression behavior when `RETURN_FLAGS_EN = 0`
- exact total-count and flag behavior for the formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no segmented count outputs yet
- no saturating or narrowed output mode yet
- no pipelined wide-vector variant yet
