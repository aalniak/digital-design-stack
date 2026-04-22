# PLL Lock Monitor Configuration Contract

## Implemented Configuration Surface

The current `pll_lock_monitor` baseline provides a conservative lock-conditioning wrapper with the following parameter set:

- `ASSERT_FILTER`
  - consecutive good samples required before `filtered_lock` can assert
  - legal values: integers `>= 1`
- `DEASSERT_FILTER`
  - consecutive bad samples required before `filtered_lock` can deassert
  - legal values: integers `>= 1`
- `STICKY_LOSS_EN`
  - enables loss-of-lock latching until `clear_sticky`
  - legal values: `0` or `1`
- `RELOCK_HOLDOFF`
  - additional consecutive good samples required before `stable_ready` can assert after lock qualification
  - legal values: integers `>= 0`
- `BYPASS_EN`
  - enables the `bypass_force_ready` override path
  - legal values: `0` or `1`

## Ports

- `clk`
  - surviving management or reference-domain clock for monitor state
- `rst_n`
  - active-low reset
- `enable`
  - enables monitoring; deasserting it forces not-ready outputs
- `raw_lock`
  - raw PLL or DLL lock indication
- `ref_ok`
  - upstream reference-health qualifier
- `reconfig_busy`
  - suppresses ready while PLL reconfiguration is active
- `clear_sticky`
  - clears `sticky_loss`
- `bypass_force_ready`
  - optional lab or simulation override when `BYPASS_EN = 1`
- `filtered_lock`
  - debounced lock status
- `stable_ready`
  - conservative ready signal after relock holdoff
- `sticky_loss`
  - sticky indication that a qualified lock was lost
- `qualifying`
  - indicates assertion qualification is actively accumulating
- `holdoff_active`
  - indicates the module has lock but has not yet released `stable_ready`
- `lock_acquired_pulse`
  - one-cycle pulse when `filtered_lock` asserts
- `lock_lost_pulse`
  - one-cycle pulse when `filtered_lock` deasserts
- `qualify_count`
  - current assertion-qualification count
- `holdoff_count`
  - current relock-holdoff count

## Behavioral Contract

- `filtered_lock` qualifies `raw_lock` through separate assertion and deassertion filters.
- `stable_ready` is more conservative than `filtered_lock`.
- Any bad sample (`raw_lock = 0`, `ref_ok = 0`, or `reconfig_busy = 1`) deasserts `stable_ready` immediately.
- `filtered_lock` only drops after `DEASSERT_FILTER` consecutive bad samples.
- After `filtered_lock` asserts, `stable_ready` only asserts after `RELOCK_HOLDOFF` additional consecutive good samples.
- `enable = 0` forces the monitor into a not-ready state.
- `bypass_force_ready` overrides the filtered path only when `BYPASS_EN = 1` and the module is out of reset.

## Current Implementation Notes

- The baseline is intentionally synchronous to a surviving management clock instead of the derived PLL output itself.
- `sticky_loss` captures qualified lock loss, not every raw-lock glitch.
- `stable_ready` is meant to drive downstream gating decisions, while `filtered_lock` remains a debounced status signal.
- reset dominates bypass so startup remains observably not-ready.

## Illegal Configurations

- `ASSERT_FILTER < 1`
- `DEASSERT_FILTER < 1`
- `STICKY_LOSS_EN` not in `{0, 1}`
- `RELOCK_HOLDOFF < 0`
- `BYPASS_EN` not in `{0, 1}`

## Planned Future Expansion

- programmable separate holdoff on initial startup versus relock
- per-cause sticky status for reference loss versus raw lock loss
- optional interrupt outputs for lock-acquired and lock-lost events
