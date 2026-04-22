# Clock Divider Configuration Contract

## Implemented Configuration Surface

The current `clock_divider` baseline provides a synchronous divide-and-tick primitive with the following parameter set:

- `DEFAULT_DIVISOR`
  - startup divide ratio
  - legal range in the current implementation: `DEFAULT_DIVISOR >= 1`
- `DIVISOR_WIDTH`
  - runtime divisor storage width
  - legal range in the current implementation: `DIVISOR_WIDTH >= 1`
- `PROGRAMMABLE_EN`
  - `1` enables runtime divisor loading through `load_divisor`
  - `0` ignores runtime load requests
- `BYPASS_EN`
  - `1` enables source-clock bypass through `bypass`
  - `0` ignores bypass requests

## Ports

- `clk`
  - source clock
- `rst_n`
  - active-low reset
- `enable`
  - enables counting and output generation
- `bypass`
  - forwards the source clock to `clk_out` when bypass support is enabled
- `load_divisor`
  - requests a runtime divisor update
- `divisor_value`
  - requested runtime divisor, with zero sanitized to one
- `clk_out`
  - logic-derived divided clock output
- `tick_pulse`
  - one-cycle pulse at divider terminal count, or every cycle in bypass mode
- `active_divisor`
  - currently applied divisor
- `pending_update`
  - indicates a runtime divisor update is queued for the next terminal-count boundary
- `running`
  - indicates the divider is enabled outside reset

## Behavioral Contract

- `tick_pulse` occurs once every `active_divisor` source-clock cycles while enabled and not bypassed.
- `clk_out` is high for `ceil(active_divisor / 2)` source-clock cycles and low for the remaining `floor(active_divisor / 2)` cycles of each divider period.
- `divisor_value = 0` is treated as `1` in the current implementation.
- If a runtime divisor load occurs while disabled or bypassed, the new divisor is applied immediately.
- If a runtime divisor load occurs while actively dividing, the update is deferred until the next terminal-count boundary and `pending_update` remains high until that boundary.

## Current Implementation Notes

- The current baseline is synchronous and logic-derived. It is intended primarily for controlled local timing references and verification exercises, not as a blanket replacement for dedicated clocking resources.
- Bypass transitions are not glitchless in the current implementation. Treat `bypass` as a configuration control that should change only under safe system-level conditions.
- `tick_pulse` intentionally stays meaningful in bypass mode and emits every source-clock cycle while enabled.
- For `active_divisor = 1`, `clk_out` remains high while enabled unless bypass is active.

## Illegal Configurations

- `DEFAULT_DIVISOR < 1`
- `DIVISOR_WIDTH < 1`
- `PROGRAMMABLE_EN` not in `{0, 1}`
- `BYPASS_EN` not in `{0, 1}`

## Planned Future Expansion

- glitchless divider wrappers that switch only through safer handoff logic
- explicit output-mode selection for tick-only or clock-only integration profiles
- stricter runtime-update policies such as load-only-when-disabled or software-acknowledged apply
- duty-shaping variants for more controlled odd-divide behavior
