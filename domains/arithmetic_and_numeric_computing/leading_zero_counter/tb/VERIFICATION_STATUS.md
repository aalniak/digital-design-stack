# Leading Zero Counter Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_leading_zero_counter_verification.ps1`

## Verified Behaviors

- all-zero input behavior with width-return count semantics
- MSB-already-set behavior
- interior highest-set-bit count and index behavior
- LSB-only highest-set-bit behavior
- index suppression when `RETURN_MSB_INDEX_EN = 0`
- exact count, `all_zero`, and highest-set-bit index behavior for the formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no pipelined variant yet
- no alternate all-zero count policy yet
- no one-hot position output yet
