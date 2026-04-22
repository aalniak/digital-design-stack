# Reset Sequencer Configuration Contract

## Implemented Configuration Surface

The current `reset_sequencer` baseline provides an ordered release controller with the following parameter set:

- `NUM_RESETS`
  - number of controlled reset outputs
  - legal values: integers `>= 1`
- `RELEASE_DELAY_CYCLES`
  - fixed spacing between each reset release step
  - legal values: integers `>= 0`
- `WAIT_FOR_PREREQ_EN`
  - enables prerequisite gating before release starts
  - legal values: `0` or `1`
- `TIMEOUT_EN`
  - enables timeout fault generation while waiting for prerequisites
  - legal values: `0` or `1`
- `TIMEOUT_CYCLES`
  - cycles allowed in prerequisite-wait state before timeout
  - legal values: integers `>= 0`
- `AUTO_RESTART_EN`
  - retains timeout behavior but keeps the FSM in wait mode instead of dropping back to idle
  - legal values: `0` or `1`

## Ports

- `clk`
  - supervisory sequencing clock
- `rst_n`
  - active-low reset
- `global_reset_req`
  - forces all controlled resets asserted and returns the sequencer to idle
- `start_sequence`
  - starts a release sequence from the fully asserted state
- `prerequisites_ready`
  - prerequisite condition for release when enabled
- `clear_fault`
  - clears latched timeout status
- `reset_asserted`
  - active-high reset requests for downstream domains
- `release_index`
  - index of the reset currently targeted for release
- `sequencing_active`
  - indicates the sequencer is waiting for prerequisites or releasing resets
- `step_release_pulse`
  - one-cycle pulse when a reset output is released
- `ready`
  - indicates the entire reset sequence completed
- `timeout_fault`
  - sticky indication that the prerequisite wait timed out

## Behavioral Contract

- The sequencer starts from the conservative state with every controlled reset asserted.
- `start_sequence` begins a new release sequence from the fully asserted state.
- When `WAIT_FOR_PREREQ_EN = 1`, release only starts after `prerequisites_ready = 1`.
- Reset outputs deassert one at a time from index `0` upward with fixed spacing of `RELEASE_DELAY_CYCLES`.
- `ready` only asserts after the last reset output is released.
- `global_reset_req` asynchronously restarts the policy state to the fully asserted idle condition on the next clock edge.

## Current Implementation Notes

- The baseline uses a uniform inter-release delay, not per-reset programmable delays.
- Timeout handling is limited to prerequisite wait, not post-release acknowledgments.
- The block owns policy ordering only; downstream reset deassertion cleanliness still belongs to local synchronizers.

## Illegal Configurations

- `NUM_RESETS < 1`
- `RELEASE_DELAY_CYCLES < 0`
- `WAIT_FOR_PREREQ_EN` not in `{0, 1}`
- `TIMEOUT_EN` not in `{0, 1}`
- `TIMEOUT_CYCLES < 0`
- `AUTO_RESTART_EN` not in `{0, 1}`

## Planned Future Expansion

- per-reset programmable delay vectors
- partial-recovery masks
- acknowledgment-driven release steps
