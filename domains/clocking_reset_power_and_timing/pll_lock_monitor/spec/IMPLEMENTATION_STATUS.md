# PLL Lock Monitor Implementation Status

## Current Status

`pll_lock_monitor` is implemented as a conservative, single-clock-domain readiness wrapper around a raw PLL lock signal.

The current implementation supports:

- assertion-side lock qualification
- deassert-side loss filtering
- immediate `stable_ready` withdrawal on any bad sample
- relock holdoff before readiness returns
- sticky loss capture with explicit clear
- optional bypass-for-ready override

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for assertion chatter rejection, qualified lock acquisition, relock holdoff, filtered loss behavior, sticky clear handling, and bypass override
- Yosys synthesis sanity
- SymbiYosys lightweight public-contract proof for reset quietness, pulse mutual exclusion, qualifying behavior, and bypass override

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_pll_lock_monitor_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- `stable_ready` is intentionally more conservative than `filtered_lock`.
- any bad sample drops `stable_ready` immediately, even before filtered loss qualification finishes
- monitoring is synchronous to `clk`, so the module can remain meaningful while the derived PLL output is unstable
- reset dominates bypass so the monitor stays quiet during startup

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- per-cause sticky reason capture
- separate startup-versus-relock qualification policies
- randomized glitch campaigns beyond the directed first-pass bench
- a deeper formal proof for exact counter latency bounds and stronger filtered-lock-to-ready relationships

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver
