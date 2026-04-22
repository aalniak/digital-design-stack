# Clock Mux Controller Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_clock_mux_controller_verification.ps1`

## Verified Behaviors

- reset-to-default source selection
- pending manual request tracking while a target source is still unhealthy
- stable-health-qualified manual switching
- invalid manual request rejection
- inhibit-switch rejection behavior
- automatic failover to the lowest-index healthy alternate source
- fault assertion when no healthy source remains
- sticky-status clear behavior

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized request-versus-health regression yet
- no deeper formal proof for manual-priority arbitration yet
- no handshake verification against a downstream physical switch block yet
