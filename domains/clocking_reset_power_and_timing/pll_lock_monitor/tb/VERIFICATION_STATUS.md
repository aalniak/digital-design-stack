# PLL Lock Monitor Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_pll_lock_monitor_verification.ps1`

## Verified Behaviors

- reset-to-not-ready behavior
- assertion-side chatter rejection before `filtered_lock` can assert
- relock holdoff before `stable_ready` can assert
- immediate `stable_ready` withdrawal on bad samples
- filtered loss after the configured deassert qualification
- sticky-loss set and clear behavior
- bypass override behavior

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized lock-chatter campaign yet
- no exact-cycle formal proof for all filter counters yet
- no separate formal reason tracking for raw-lock loss versus reference or reconfiguration causes
