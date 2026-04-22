# Glitchless Clock Switch Configuration Contract

## Implemented Configuration Surface

The current `glitchless_clock_switch` baseline provides a two-source glitchless handoff primitive with the following parameter set:

- `DEFAULT_SOURCE`
  - startup-selected source after reset
  - legal values: `0` for `clk_a`, `1` for `clk_b`
- `STATUS_EN`
  - retained for interface-family compatibility in this baseline
  - legal values: `0` or `1`

## Ports

- `clk_a`
  - source clock 0
- `clk_b`
  - source clock 1
- `rst_n`
  - active-low reset
- `select_req`
  - requested source selection
- `switched_clk`
  - glitchless switched output clock
- `active_select`
  - currently granted source selection when valid
- `active_select_valid`
  - indicates one source currently owns the output clock
- `source_a_active`
  - internal ownership indication for source A
- `source_b_active`
  - internal ownership indication for source B
- `switch_busy`
  - reset-quiet indication that the granted source does not yet match the request or the switch is in the handoff gap

## Behavioral Contract

- This baseline supports exactly two source clocks.
- `select_req` is synchronized independently into each source domain.
- A requester must hold `select_req` stable until `switch_busy` deasserts.
- Each source gate can only turn on after a synchronized observation that the opposite source gate has turned off.
- Gate ownership changes only on the low phase of the respective source clock.
- `switched_clk` is the OR of the two gated clocks, with mutual exclusion enforced by the gate controls.
- During handoff there can be a brief valid-low ownership gap, which is reported through `active_select_valid = 0` and `switch_busy = 1`.

## Current Implementation Notes

- This baseline is an RTL structural model of a glitchless two-source switch, not a foundry- or FPGA-primitive binding layer.
- A stopped target source can leave the switch waiting in the handoff gap because the new source gate only turns on at a legal clock edge.
- The module owns edge integrity only. It does not interpret source health or source legality.

## Illegal Configurations

- `DEFAULT_SOURCE` not in `{0, 1}`
- `STATUS_EN` not in `{0, 1}`

## Planned Future Expansion

- explicit hardened-primitive wrapper profiles
- more than two source inputs with encoded or one-hot selection
- optional inserted dead-time controls and switch-accept acknowledgment
