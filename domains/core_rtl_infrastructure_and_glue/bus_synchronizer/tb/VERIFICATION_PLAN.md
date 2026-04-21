# Bus Synchronizer Verification Plan

## Verification Scope

- Module under test: `bus_synchronizer`
- Current profile: single-entry request or acknowledge handshake

## Verification Intent

The main risks are:

- torn or reordered bus delivery
- duplicated or missing word transfers
- failure to hold destination data stable while waiting for `dst_ready`
- failure to return to idle after reset

## Planned Checks

Simulation:

- randomized accepted source words are delivered in order
- destination stalls preserve stable `dst_data` while `dst_valid` is asserted
- each accepted source word produces one destination arrival pulse
- reset returns the synchronizer to an idle state

Formal:

- destination reset clears `dst_valid` and `dst_pulse`
- source reset returns `src_ready`
- `dst_valid` holding behavior is stable until `dst_ready`
- `dst_pulse` only appears together with a valid destination word

Synthesis sanity:

- parse and optimize cleanly with Yosys

## Current Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_bus_synchronizer_verification.ps1`
