# Timer Block Implementation Status

## Current Status

`timer_block` is implemented and verified as the reusable programmable countdown timer for one-shot and periodic control-plane timing.

The current implementation supports:

- configurable active count width through `COUNT_WIDTH`
- optional programmable prescaling through `PRESCALE_WIDTH`
- direct `start`, `stop`, `clear`, and `load` control pulses
- periodic reload through `reload_value`
- sticky interrupt generation with explicit acknowledge

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- directed one-shot timer simulation
- directed periodic reload simulation
- directed stop, clear, load, and interrupt-acknowledge simulation
- directed programmable prescaler simulation
- Yosys synthesis sanity
- SymbiYosys formal proof of reset-safety public-contract invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_timer_block_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The current timer is a countdown design rather than an elapsed-time compare design.
- `start_pulse` always reloads from `load_value` and therefore acts as a restart command.
- `load_pulse` reprograms the live count without altering running state.
- Sticky interrupt state is cleared by `irq_ack`, `clear_pulse`, or `start_pulse`.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- compare-match or capture timestamp outputs
- free-running timebase sharing interfaces
- pulse-style interrupt output separate from sticky `irq`
- automated parameter sweeps across larger count and prescaler widths
- deeper formal proofs for control-collision semantics and periodic timing cadence

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Expand verification breadth
   - add parameter sweeps over count width and prescaler width
   - add stronger formal properties around control-priority and periodic cadence

2. Grow the family shape
   - add capture/compare variants
   - add bus-facing wrappers with register-mapped control surfaces

3. Improve integration visibility
   - add elapsed-time or next-expiration visibility where software integration benefits
