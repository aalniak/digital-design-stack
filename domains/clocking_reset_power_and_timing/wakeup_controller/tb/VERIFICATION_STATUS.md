# Wakeup Controller Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_wakeup_controller_verification.ps1`

## Verified Behaviors

- reset clears pending wake state
- enabled level-triggered wake latches sticky pending state
- enabled rising-edge wake triggers on a clean sampled transition
- disabled sources do not create pending wake state
- clear masks remove only the requested pending bits

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no synchronizer wrapper for asynchronous wake inputs yet
- no falling-edge or polarity-inverted modes yet
- no randomized long-run toggle regression yet
