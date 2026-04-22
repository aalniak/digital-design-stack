# Wakeup Controller Configuration Contract

## Implemented Configuration Surface

The current `wakeup_controller` baseline provides a wake-source aggregation policy block with the following parameter set:

- `NUM_SOURCES`
  - number of wake sources presented to the controller
  - legal values: integers `>= 1`

## Ports

- `clk`
  - supervisory clock for wake qualification and sticky pending state
- `rst_n`
  - active-low reset
- `sleep_armed`
  - enables wake-request generation toward the rest of the power-management stack
- `source_level`
  - raw sampled wake-source levels
- `enable_mask`
  - per-source enable bits
- `edge_mask`
  - selects rising-edge wake behavior when set, or level-high wake behavior when clear
- `clear_pending_mask`
  - per-source clear for sticky pending wake bits
- `pending_mask`
  - sticky pending wake status after enable and trigger qualification
- `active_wake_mask`
  - enabled subset of pending wake bits
- `wake_request`
  - aggregate wake request when sleep is armed and at least one pending wake exists
- `wake_pulse`
  - one-cycle pulse on newly detected enabled wake events while sleep is armed

## Behavioral Contract

- Edge-qualified sources trigger on a rising transition.
- Level-qualified sources trigger whenever the sampled source is high.
- Pending wake bits are sticky until explicitly cleared through `clear_pending_mask`.
- Disabled sources do not create pending state.
- `wake_request` is only asserted while `sleep_armed = 1`.

## Current Implementation Notes

- The baseline assumes wake sources are already synchronized into `clk`.
- `wake_pulse` reflects newly detected events, while `wake_request` reflects sticky pending state.
- Mask changes take effect immediately for new qualification and for the exported `active_wake_mask`.

## Illegal Configurations

- `NUM_SOURCES < 1`

## Planned Future Expansion

- per-source debounce or filter stages
- explicit polarity selection beyond rising-edge and active-high level modes
- cross-domain synchronizer wrappers for asynchronous wake inputs
