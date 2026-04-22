# Clock Mux Controller Implementation Status

## Current Status

`clock_mux_controller` is implemented as a first reusable clock-source policy block that separates request handling and health interpretation from the eventual physical switch fabric.

The current implementation supports:

- manual source requests with range checking
- optional stable-health qualification before a switch commits
- automatic failover to a healthy alternate source
- post-switch hold coordination through `switch_in_progress` and `hold_request`
- sticky or live status reporting for faults and auto-failover history

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for reset behavior, delayed stable-qualification switching, invalid request rejection, inhibited request rejection, automatic failover, and no-source-healthy fault behavior
- Yosys synthesis sanity
- SymbiYosys formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_clock_mux_controller_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The baseline treats `mux_select` and `active_source` as the same committed source selection.
- Manual requests outrank automatic failover.
- Automatic failover chooses the lowest-index healthy alternate source.
- The post-switch hold window is a policy aid for surrounding reset or gating logic, not a proof of physical switch completion.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- handshake-based confirmation from a downstream glitchless switch block
- programmable source-priority tables or hysteresis policies
- richer fault-cause reporting for manual versus automatic control failures
- deeper formal checks for priority, waiting, and hold-window sequencing

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Improve switch-policy realism
   - add explicit switch-acknowledge integration with the physical switch fabric
   - add configurable failover priority policies and hysteresis

2. Improve observability
   - add explicit cause bits for rejected requests and no-source-healthy conditions
   - separate waiting-for-stable state from post-switch hold state

3. Expand verification breadth
   - add randomized health-signal and request-sequence regressions
   - add deeper formal checks for manual-priority and failover determinism
