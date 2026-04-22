# Power Domain Controller Configuration Contract

## Implemented Configuration Surface

The current `power_domain_controller` baseline provides a supervisory-domain policy sequencer with the following parameters:

- `POWER_UP_DELAY_CYCLES`
  - number of consecutive `power_good` cycles required before the domain is considered ready to enter restore or active state
  - legal values: integers `>= 0`
- `POWER_DOWN_DELAY_CYCLES`
  - number of cycles the controller keeps power enabled after asserting the safe shutdown controls
  - legal values: integers `>= 0`
- `SAVE_TIMEOUT_CYCLES`
  - cycles allowed for retention save completion after shutdown begins
  - legal values: integers `>= 0`
- `RESTORE_TIMEOUT_CYCLES`
  - cycles allowed for restore completion after a retained power-up
  - legal values: integers `>= 0`
- `RETENTION_EN`
  - enables retention save and restore sequencing
  - legal values: `0` or `1`

## Ports

- `clk`
  - supervisory always-on sequencing clock
- `rst_n`
  - active-low reset for the controller itself
- `power_on_req`
  - requests domain bring-up from the powered-off state
- `power_off_req`
  - requests orderly domain shutdown from the active state
- `power_good`
  - indicates the target domain power rail is stable
- `save_done`
  - acknowledgment from external retention-save logic
- `restore_done`
  - acknowledgment from external restore logic
- `clear_fault`
  - clears sticky timeout fault status while powered off
- `power_enable`
  - requests domain power to be applied
- `isolation_enable`
  - keeps boundary isolation asserted until the domain is fully active
- `clock_gate_enable`
  - holds the domain clock gated until bring-up is complete or shutdown begins
- `domain_reset_asserted`
  - keeps the domain in reset until bring-up is complete or shutdown begins
- `retention_save_pulse`
  - one-cycle pulse to request context save before power-down
- `retention_restore_pulse`
  - one-cycle pulse to request context restore after power-up
- `retention_context_valid`
  - indicates a saved retention image exists and should be restored on the next successful power-up
- `sequencing_active`
  - indicates the controller is in a transitional sequencing state
- `domain_active`
  - indicates the domain is fully powered, unisolated, ungated, and out of reset
- `fault_timeout`
  - sticky timeout fault status for save or restore failures
- `state_code`
  - encoded observable state for debug and integration

## Behavioral Contract

- The controller starts in a conservative powered-off state with isolation, reset, and clock-gate controls asserted.
- `power_on_req` starts the bring-up sequence from `OFF` when no sticky fault is present.
- `power_good` must remain high for `POWER_UP_DELAY_CYCLES` before the controller enters `ACTIVE` or `RESTORE`.
- If `RETENTION_EN = 1` and `retention_context_valid = 1`, the controller requests restore before releasing the domain to active operation.
- `power_off_req` from `ACTIVE` requests retention save when enabled and then powers the domain down after `POWER_DOWN_DELAY_CYCLES`.
- Save or restore timeouts set `fault_timeout` and force a safe power-down.
- `clear_fault` only clears the sticky timeout flag while the controller is powered off.

## Current Implementation Notes

- This first baseline owns sequencing policy only; it does not model analog ramp behavior or distributed acknowledgment fan-in.
- Output ownership is deliberately centralized so that isolation, reset, clock gate, and power enable move together under one FSM.
- `retention_context_valid` persists across power-off and is cleared only after a successful restore.

## Illegal Configurations

- `POWER_UP_DELAY_CYCLES < 0`
- `POWER_DOWN_DELAY_CYCLES < 0`
- `SAVE_TIMEOUT_CYCLES < 0`
- `RESTORE_TIMEOUT_CYCLES < 0`
- `RETENTION_EN` not in `{0, 1}`

## Planned Future Expansion

- per-step programmable delay vectors
- separate fault codes for save timeout versus restore timeout
- explicit software handshakes for force-off and force-on overrides
- integrated wakeup and reset dependency checks
