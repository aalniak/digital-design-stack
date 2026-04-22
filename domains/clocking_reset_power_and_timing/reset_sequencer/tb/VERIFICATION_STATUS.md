# Reset Sequencer Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_reset_sequencer_verification.ps1`

## Verified Behaviors

- reset-to-idle startup with every controlled reset asserted
- prerequisite timeout while all reset outputs remain asserted
- sticky timeout reporting until `clear_fault`
- retry after fault clear
- ordered release from index `0` upward with fixed inter-step delay
- `ready` assertion on the final release step
- restart to the fully asserted idle state on `global_reset_req`

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized restart or fault-injection regression yet
- no formal proof of per-step timing beyond the lightweight public contract
- no support yet for per-reset delay vectors or acknowledgment-driven release
