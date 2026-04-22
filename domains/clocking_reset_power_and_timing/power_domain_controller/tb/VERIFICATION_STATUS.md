# Power Domain Controller Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_power_domain_controller_verification.ps1`

## Verified Behaviors

- reset-to-safe powered-off startup
- qualified power-up after stable `power_good`
- retention save request on shutdown
- retained restore request on the next successful power-up
- sticky restore-timeout fault handling and safe return to powered-off state
- fault clear while powered off followed by successful retry

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized long-run power-cycling regression yet
- no split fault classification for save timeout versus restore timeout
- no end-to-end proof of every multi-step transition path
