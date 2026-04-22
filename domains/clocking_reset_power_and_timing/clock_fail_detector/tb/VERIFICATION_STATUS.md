# Clock Fail Detector Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_clock_fail_detector_verification.ps1`

## Verified Behaviors

- reset-to-idle behavior with all public status outputs quiet
- healthy monitored-clock operation within the configured edge window
- timeout event generation after monitored-clock loss
- sticky-fault hold behavior until explicit clear
- non-sticky auto recovery after healthy monitored activity returns
- slow-clock window violation detection
- fast-clock window violation detection

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized jitter or missing-edge campaign yet
- no deeper formal proof for timeout latency bounds or filter-depth qualification yet
- no per-cause sticky status outputs yet
