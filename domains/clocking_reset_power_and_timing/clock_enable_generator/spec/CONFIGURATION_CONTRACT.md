# Clock Enable Generator Configuration Contract

## Implemented Configuration Surface

The current `clock_enable_generator` baseline provides a synchronous pacing primitive with the following parameter set:

- `DEFAULT_PERIOD`
  - startup pulse interval in source-clock cycles
  - legal range in the current implementation: `DEFAULT_PERIOD >= 1` and `DEFAULT_PERIOD >= PULSE_WIDTH`
- `PERIOD_WIDTH`
  - runtime period storage width
  - legal range in the current implementation: `PERIOD_WIDTH >= 1`
- `PULSE_WIDTH`
  - number of consecutive source-clock cycles for which `enable_pulse` stays high inside each period
  - legal range in the current implementation: `PULSE_WIDTH >= 1`
- `PROGRAMMABLE_EN`
  - `1` enables runtime period changes through `load_period`
  - `0` ignores runtime load requests
- `RESTART_ON_WRITE`
  - `1` applies a new runtime period immediately and restarts phase
  - `0` queues a new runtime period until the next period boundary
- `BYPASS_EN`
  - `1` enables always-on pacing through `bypass`
  - `0` ignores bypass requests

## Ports

- `clk`
  - source clock
- `rst_n`
  - active-low reset
- `enable`
  - global enable for pulse generation
- `bypass`
  - forces `enable_pulse` high every enabled cycle when bypass support is enabled
- `load_period`
  - requests a runtime period update
- `period_value`
  - requested runtime period, sanitized to at least `PULSE_WIDTH`
- `enable_pulse`
  - synchronous gating pulse output
- `active_period`
  - currently applied period
- `phase_count`
  - current position inside the active period
- `pending_update`
  - indicates a queued runtime period update is waiting for a boundary
- `running`
  - indicates the block is enabled outside reset

## Behavioral Contract

- `enable_pulse` stays high for the last `PULSE_WIDTH` source-clock cycles of each period.
- With `PULSE_WIDTH = 1`, the module emits a one-cycle pulse every `active_period` source-clock cycles.
- If `period_value` is smaller than `PULSE_WIDTH`, the requested runtime period is clamped upward to `PULSE_WIDTH`.
- If a runtime period load occurs while disabled or bypassed, the new period is applied immediately.
- If a runtime period load occurs while actively generating pulses:
  - `RESTART_ON_WRITE = 1` applies the new period immediately and restarts phase
  - `RESTART_ON_WRITE = 0` queues the new period until the next period boundary

## Current Implementation Notes

- The current baseline stays entirely in one clock domain and is intended to be the safer alternative to a logic-derived divided clock for most pacing problems.
- Phase always restarts from zero when the block is disabled, bypassed, or restarted on write.
- In bypass mode, `enable_pulse` is high on every enabled cycle.
- The current implementation provides stable observability through `active_period`, `phase_count`, and `pending_update`.

## Illegal Configurations

- `DEFAULT_PERIOD < 1`
- `PERIOD_WIDTH < 1`
- `PULSE_WIDTH < 1`
- `DEFAULT_PERIOD < PULSE_WIDTH`
- `PROGRAMMABLE_EN` not in `{0, 1}`
- `RESTART_ON_WRITE` not in `{0, 1}`
- `BYPASS_EN` not in `{0, 1}`

## Planned Future Expansion

- optional explicit pulse-start offset control
- programmable pulse width
- wrapper profiles that expose a narrower port set for fixed-period use cases
- deeper timing-status outputs for software-observed pacing subsystems
