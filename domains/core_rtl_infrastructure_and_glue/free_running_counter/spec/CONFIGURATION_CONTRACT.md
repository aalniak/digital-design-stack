# Free-Running Counter Configuration Contract

## Implemented Configuration Surface

The current `free_running_counter` implementation provides a reusable local timebase primitive with the following parameter set:

- `COUNT_WIDTH`
  - width of the live counter and capture register
  - legal range in the current implementation: `COUNT_WIDTH >= 1`
- `RESET_VALUE`
  - reset and load-clear startup value for the counter and capture register
- `ENABLE_EN`
  - `1` means the public `enable` input gates counting
  - `0` means the counter advances every cycle regardless of `enable`
- `ROLLOVER_PULSE_EN`
  - `1` enables the one-cycle rollover pulse output
  - `0` forces the pulse low while keeping a stable port set
- `CAPTURE_EN`
  - `1` enables explicit capture through `capture`
  - `0` makes `capture_value` mirror the live count for a stable interface

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `enable`
  - optional count gating input when `ENABLE_EN = 1`
- `load`
  - synchronous load request with priority over counting
- `load_value`
  - value loaded into the counter when `load` is asserted
- `capture`
  - captures the post-update visible count into `capture_value` when enabled
- `count_value`
  - live free-running count value
- `capture_value`
  - captured or mirrored count value depending on `CAPTURE_EN`
- `rollover_pulse`
  - one-cycle pulse when a counted increment wraps from max back to zero and the pulse feature is enabled

## Behavioral Contract

- `load` has priority over counting.
- When `ENABLE_EN = 1`, the counter advances only if `enable = 1` and `load = 0`.
- When `ENABLE_EN = 0`, the counter advances every cycle except when `load = 1`.
- `capture` records the post-update visible count for that cycle.
- `rollover_pulse` only indicates a counted wrap event, not an arbitrary load.
- The block is local to one clock domain; exported values should be captured before CDC crossing.

## Current Implementation Notes

- The current RTL keeps a stable public port set even when enable, capture, or rollover features are disabled.
- The first-pass family focuses on the base timebase primitive rather than compare or timer wrappers.
- Capture semantics are intentionally aligned with the post-update visible value so downstream logic sees a coherent timestamp.

## Illegal Configurations

- `COUNT_WIDTH < 1`

## Planned Future Expansion

- compare outputs and match pulse generation
- optional pause-free shadow capture bank
- optional prescaler or programmable tick divider wrapper
- CSR-facing wrappers for software timestamp capture
