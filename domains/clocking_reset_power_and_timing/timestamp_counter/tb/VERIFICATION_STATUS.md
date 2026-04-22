# Timestamp Counter Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_timestamp_counter_verification.ps1`

## Verified Behaviors

- reset-to-zero startup
- unit-step incrementing with `tick_pulse`
- pre-update capture behavior
- synchronous load override
- post-update compare-hit pulse generation
- overflow pulse on wraparound

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no programmable increment step yet
- no multi-channel capture support yet
- no stronger formal proof of sampled control timing yet
