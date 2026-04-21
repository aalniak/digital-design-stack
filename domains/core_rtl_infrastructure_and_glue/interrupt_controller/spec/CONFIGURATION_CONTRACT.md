# Interrupt Controller Configuration Contract

## Implemented Configuration Surface

The current `interrupt_controller` implementation provides a reusable fixed-priority interrupt fan-in block with the following parameter set:

- `NUM_SOURCES`
  - number of incoming interrupt or event sources
  - legal range in the current implementation: `NUM_SOURCES >= 1`

## Ports

- `clk`
  - local synchronous control clock
- `rst_n`
  - active-low reset
- `src_event`
  - observed source events, assumed already safe in the local clock domain
- `src_level_mode`
  - per-source mode bit
  - `1` selects level-sensitive behavior
  - `0` selects rising-edge-latched behavior
- `enable_mask`
  - per-source enable mask
- `sw_set`
  - per-source software or synthetic pending set
- `ack_mask`
  - per-source acknowledge or clear request
- `raw_status`
  - direct view of `src_event`
- `pending_status`
  - effective pending state before masking
- `active_onehot`
  - one-hot selected source after applying `enable_mask`
- `irq`
  - aggregate interrupt request
- `irq_id`
  - selected source ID for the active request

## Behavioral Contract

- Priority is fixed and deterministic: lower source index has higher priority.
- Edge-mode sources latch on rising edges of `src_event`.
- Level-mode sources are considered pending whenever the corresponding `src_event` bit is high.
- `sw_set` sets sticky pending state regardless of source mode.
- Sticky pending state from edge-mode sources remains set until acknowledged through `ack_mask`.
- For level-mode sources, acknowledging while `src_event` remains high does not suppress the request; the source must deassert to remove the effective pending state.
- `enable_mask` affects delivery and selection, not pending capture.
- `pending_status` is visible even when a source is masked off.
- `active_onehot`, `irq`, and `irq_id` reflect the highest-priority enabled pending source.
- Reset clears edge-latched pending state and suppresses level-mode delivery until reset is released.

## Current Implementation Notes

- The current baseline is a single-output controller with vector output through `irq_id`.
- The first-pass priority policy is fixed low-index-first rather than programmable.
- `ack_mask` uses set-wins semantics for edge-mode sources: a new event or `sw_set` in the same cycle is not lost to the acknowledge.

## Illegal Configurations

- `NUM_SOURCES < 1`

## Planned Future Expansion

- multi-output or target-group routing
- programmable priority maps
- explicit active-in-service state tracking
- optional pulse stretching or event conditioning wrappers
