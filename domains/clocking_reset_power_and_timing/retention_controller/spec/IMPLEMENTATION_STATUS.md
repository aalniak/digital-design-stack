# Retention Controller Implementation Status

## Current Status

`retention_controller` is implemented as a small dedicated handshake owner for retention save and restore policy.

The current implementation supports:

- save requests gated by domain-idle qualification
- restore requests gated by power-good and saved-context validity
- sticky retained-context tracking
- timeout faulting for incomplete save or restore transactions
- fault clear while idle

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for save success, restore success, restore timeout, fault clear, and retry
- Yosys synthesis sanity
- SymbiYosys lightweight public-contract proof

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_retention_controller_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- the controller never starts save unless `domain_idle` is already asserted
- the controller never starts restore without both `domain_power_good` and a valid saved context
- timeout faults are sticky until `clear_fault` while idle

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- multi-bank or hierarchical retention images
- explicit cancel support while busy
- randomized repeated save and restore regressions
- split fault-class reporting

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver
