# Clock Enable Generator Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_clock_enable_generator_verification.ps1`

## Verified Behaviors

- reset-to-idle output behavior
- one-cycle pulse spacing for period 4
- deferred runtime update from 4 to 5
- two-cycle pulse window for period 5
- immediate restart-on-write from 6 to 3
- disabled output quiescence
- bypass behavior and immediate apply while bypassed

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized runtime-write regression yet
- no deeper formal proof for no-missing-pulse and no-double-pulse behavior yet
- no programmable runtime pulse-width support yet
