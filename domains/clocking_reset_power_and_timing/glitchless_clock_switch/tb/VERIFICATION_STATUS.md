# Glitchless Clock Switch Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_glitchless_clock_switch_verification.ps1`

## Verified Behaviors

- reset-to-default source selection
- handoff from source A to source B with a visible busy interval
- handoff from source B back to source A
- mutual-exclusion source ownership
- switched-clock edge activity from the currently granted source
- public status consistency for `active_select`, `active_select_valid`, and `switch_busy`

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no primitive-specific gate-level verification yet
- no explicit stopped-target-clock regression yet
- formal assumes the controller holds `select_req` stable while `switch_busy` is asserted
