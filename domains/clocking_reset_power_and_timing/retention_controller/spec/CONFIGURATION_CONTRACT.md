# Retention Controller Configuration Contract

## Implemented Configuration Surface

The current `retention_controller` baseline provides a dedicated save and restore handshake controller with the following parameters:

- `SAVE_TIMEOUT_CYCLES`
  - cycles allowed for external save completion
  - legal values: integers `>= 0`
- `RESTORE_TIMEOUT_CYCLES`
  - cycles allowed for external restore completion
  - legal values: integers `>= 0`

## Ports

- `clk`
  - supervisory clock for save and restore policy
- `rst_n`
  - active-low reset
- `save_req`
  - requests a retention save operation
- `restore_req`
  - requests a retention restore operation
- `domain_idle`
  - indicates the target domain is quiescent enough to save state
- `domain_power_good`
  - indicates the target domain is powered and eligible for restore
- `save_done`
  - external acknowledgment for completed save operation
- `restore_done`
  - external acknowledgment for completed restore operation
- `clear_fault`
  - clears sticky timeout status while idle
- `save_pulse`
  - one-cycle pulse that starts a save transaction
- `restore_pulse`
  - one-cycle pulse that starts a restore transaction
- `retention_valid`
  - indicates a saved context image exists
- `busy`
  - indicates the controller is waiting for save or restore completion
- `fault_timeout`
  - sticky timeout fault for save or restore failures
- `state_code`
  - encoded observable controller state

## Behavioral Contract

- Save requests are accepted only while `domain_idle = 1` and no sticky fault is present.
- Successful save completion sets `retention_valid`.
- Restore requests are accepted only when `domain_power_good = 1`, `retention_valid = 1`, and no sticky fault is present.
- Successful restore completion clears `retention_valid`.
- Save or restore timeout sets `fault_timeout` and returns the controller to idle.
- `clear_fault` only clears the sticky timeout flag while idle.

## Current Implementation Notes

- The baseline owns transaction start policy only; actual state capture and restore datapaths live outside the block.
- Save and restore are serialized through a single controller state machine.
- `retention_valid` remains set after a restore timeout so software can decide the next recovery policy.

## Illegal Configurations

- `SAVE_TIMEOUT_CYCLES < 0`
- `RESTORE_TIMEOUT_CYCLES < 0`

## Planned Future Expansion

- separate fault codes for save timeout and restore timeout
- multi-bank retention save and restore sequencing
- explicit cancel or retry controls while busy
