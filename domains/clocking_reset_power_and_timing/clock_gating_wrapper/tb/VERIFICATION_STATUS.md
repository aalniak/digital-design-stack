# Clock Gating Wrapper Verification Status

## Current Result

- simulation: pass
- Yosys synthesis sanity: pass
- SymbiYosys formal: pass

## Verification Entry Point

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_clock_gating_wrapper_verification.ps1`

## Verified Behaviors

- reset-closed startup for the default-disabled profile
- accepted gate-state changes only on the low phase of `clk_in`
- open and close behavior for synchronized enable requests
- test bypass override behavior
- functional bypass override behavior
- FPGA-safe free-running-clock behavior with policy exported through `domain_ce`
- active-low enable polarity behavior

## Artifacts

- simulation and formal outputs are written under `tb/out/`

## Known Gaps

- no randomized phase-sweep regression for control changes yet
- no deeper formal proof for no-extra-edge closure guarantees yet
- no foundry-cell mapping check yet
