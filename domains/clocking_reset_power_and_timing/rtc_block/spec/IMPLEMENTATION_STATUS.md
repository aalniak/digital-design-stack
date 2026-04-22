# RTC Block Implementation Status

## Current Status

`rtc_block` is implemented as a prescaled always-on counter with set-time control and one programmable sticky alarm.

The current implementation supports:

- prescaled RTC time incrementing
- synchronous set-time behavior
- one programmable enabled alarm register
- one-cycle alarm pulse plus sticky alarm-pending flag
- sticky alarm clear without disarming the alarm register

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for prescaled counting, alarm fire, pending clear, set-time, and re-armed alarm behavior
- Yosys synthesis sanity
- SymbiYosys lightweight public-contract proof

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_rtc_block_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- this block counts generic RTC ticks rather than encoding calendar fields
- alarms stay enabled after they fire
- set-time resets the prescaler phase for deterministic re-alignment

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- periodic alarm modes
- multiple alarm registers
- calendar conversion logic
- stronger formal proof of alarm timing under arbitrary reprogramming

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver
