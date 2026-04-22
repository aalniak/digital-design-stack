# Barrel Shifter Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_barrel_shifter_verification.ps1`

## Verified Behaviors

- logical left shift with sticky reporting
- logical right shift with sticky reporting
- arithmetic right shift with sign extension and sticky reporting
- rotate-left behavior with zero sticky
- oversize logical-left shift behavior
- oversize arithmetic-right sign-fill behavior
- sticky suppression when `STICKY_BIT_EN = 0`
- exact mode-specific result and sticky behavior for the formal configuration

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no rotate-right mode yet
- no shifted-out bus output yet
- no pipelined high-frequency implementation yet
