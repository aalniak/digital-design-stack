# Glitchless Clock Switch Implementation Status

## Current Status

`glitchless_clock_switch` is implemented as a first reusable two-source physical clock-handoff primitive with explicit ownership status outputs.

The current implementation supports:

- two-source glitchless handoff
- low-phase gate ownership changes
- independent request synchronization into each source domain
- synchronized opposite-gate observation before the new source is enabled
- explicit ownership-valid and busy reporting

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for default-source startup, handoff to source B, handoff back to source A, mutual-exclusion ownership, and output-clock activity on both sources
- Yosys synthesis sanity
- SymbiYosys formal public-contract proof under the documented stable-request-during-busy assumption

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_glitchless_clock_switch_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The baseline is intentionally limited to two sources.
- Ownership status is explicit so higher layers can observe the handoff gap.
- The module expects the controller above it to keep `select_req` stable until a handoff completes.
- The module does not hide source-health policy or failover policy internally.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- hardened primitive mapping
- multi-source switching beyond two inputs
- explicit handling for stopped target clocks beyond exposing the busy gap
- deeper formal checks for asynchronous phase interleavings

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver
