# Pulse Synchronizer Verification Plan

## Verification Scope

- Module under test: `pulse_synchronizer`
- Current profile: toggle-based event transfer with source-side busy indication

## Verification Intent

The main risks are:

- missing an accepted source pulse
- duplicating a source pulse at the destination
- failing to return to idle after reset
- mishandling overlap when the source pulses while busy

## Planned Checks

Simulation:

- one accepted source pulse produces one destination pulse
- many randomized source pulses across unrelated clocks preserve one-to-one transfer for accepted events
- busy blocks overlapping launches
- reset returns the path to idle

Formal:

- no destination pulse during destination reset
- no busy indication during source reset
- at most one event is in flight at a time
- no destination pulse occurs without an accepted source event in flight

Synthesis sanity:

- parse and optimize cleanly with Yosys

## Current Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_pulse_synchronizer_verification.ps1`
