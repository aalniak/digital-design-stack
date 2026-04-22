# PPS Capture Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_pps_capture_verification.ps1`

## Verified Behaviors

- first-capture behavior without an interval delta
- interval measurement on later captures
- glitch rejection and sticky clear handling
- filtered rising-edge capture
- falling-edge capture in an alternate profile

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized PPS jitter campaign yet
- no explicit missing-pulse or double-pulse classification yet
- simulation uses a direct-sample profile for deterministic filter testing, while the lightweight formal harness covers the synchronized profile
