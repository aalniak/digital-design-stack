# Clock Divider Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_clock_divider_verification.ps1`

## Verified Behaviors

- reset-to-idle output behavior
- divide-by-4 tick spacing
- deferred runtime divisor update from 4 to 5
- odd-divide high-phase behavior for divide-by-5
- disabled output quiescence
- bypass-mode clock forwarding and immediate divisor load while bypassed
- divide-by-3 restart after leaving bypass

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized reprogramming regression yet
- no deeper formal proof of boundary-aligned apply behavior yet
- no glitchless bypass guarantee in the current implementation
