# Power Domain Controller Implementation Status

## Current Status

`power_domain_controller` is implemented as a supervisory FSM that sequences power application, safe shutdown controls, optional retention handshakes, and sticky timeout fault handling for a single target domain.

The current implementation supports:

- conservative powered-off startup state
- power-up qualification through `power_good` plus programmable delay
- optional retention restore before the domain becomes active
- active-state shutdown requests with optional retention save
- controlled power-down delay after safe shutdown controls assert
- sticky timeout fault handling for failed save or restore operations

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for basic power-up, save-driven power-down, retained power-up and restore, restore timeout faulting, fault clear, and retry
- Yosys synthesis sanity
- SymbiYosys lightweight public-contract proof

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_power_domain_controller_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- the module assumes a single supervisory clock domain owns all sequencing policy
- safe shutdown controls assert before power is removed and remain asserted while powered off
- timeout faults are sticky until `clear_fault` is asserted while powered off
- restore is only requested when retained context is actually marked valid

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- multiple independent power-good or handshake sources
- separate save and restore fault-class outputs
- hierarchical sequencing across parent and child domains
- randomized long-run power-cycling regressions

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver
