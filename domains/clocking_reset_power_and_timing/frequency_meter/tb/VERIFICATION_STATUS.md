# Frequency Meter Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_frequency_meter_verification.ps1`

## Verified Behaviors

- reset and disabled-idle output behavior
- one-shot in-range measurement for a known clock ratio
- one-shot above-range measurement for a faster target clock
- one-shot stopped-clock measurement with zero-count result
- continuous repeated sampling
- transitional then settled samples after an abrupt measured-clock rate change
- exponential moving-average update behavior
- disable clearing `busy`, `result_valid`, and threshold flags

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized phase-jitter campaign yet
- no direct fixed-point Hertz scaling output yet
- no deeper formal proof for continuous restart and averaging evolution yet
