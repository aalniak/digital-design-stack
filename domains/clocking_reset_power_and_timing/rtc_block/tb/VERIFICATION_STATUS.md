# RTC Block Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_rtc_block_verification.ps1`

## Verified Behaviors

- reset-to-zero startup with alarm disabled
- prescaled RTC time incrementing
- programmed alarm pulse and sticky pending flag
- alarm-pending clear behavior
- set-time override and re-armed alarm behavior

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no periodic alarm modes yet
- no multiple-alarm support yet
- no stronger formal proof of prescaler timing under reprogramming yet
