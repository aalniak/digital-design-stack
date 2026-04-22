# Retention Controller Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_retention_controller_verification.ps1`

## Verified Behaviors

- reset-to-idle startup with no saved context
- save success path that sets `retention_valid`
- restore success path that clears `retention_valid`
- restore-timeout fault path with sticky retained-context preservation
- fault clear while idle followed by successful retry

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no multi-bank retention sequencing yet
- no split save-timeout versus restore-timeout fault reporting yet
- no randomized repeated transaction regression yet
