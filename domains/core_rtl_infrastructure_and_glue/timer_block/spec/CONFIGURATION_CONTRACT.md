# Timer Block Configuration Contract

## Implemented Configuration Surface

The current `timer_block` implementation provides a reusable programmable timer primitive with the following parameter set:

- `COUNT_WIDTH`
  - width of the active countdown register
  - legal range in the current implementation: `COUNT_WIDTH >= 1`
- `PRESCALE_WIDTH`
  - width of the optional prescaler divider register
  - legal range in the current implementation: `PRESCALE_WIDTH >= 0`
  - `PRESCALE_WIDTH = 0` removes programmable prescaling and causes the timer to advance every clock cycle

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `start_pulse`
  - restarts the timer from `load_value`
- `stop_pulse`
  - stops the timer without clearing the current count
- `clear_pulse`
  - clears running state, pending interrupt state, count, and prescaler state
- `load_pulse`
  - loads `load_value` into the active count register without changing running state
- `periodic_en`
  - enables reload from `reload_value` on expiration
- `irq_enable`
  - enables sticky interrupt assertion on expiration
- `irq_ack`
  - clears a pending interrupt
- `load_value`
  - countdown value used by `start_pulse` and `load_pulse`
- `reload_value`
  - countdown value reloaded after expiration when `periodic_en = 1`
- `prescale_div`
  - programmed prescaler divider
  - when prescaling is enabled, a timer decrement occurs every `prescale_div + 1` clocks
- `running`
  - indicates the timer is active
- `expire_pulse`
  - one-cycle pulse on each expiration event
- `irq`
  - sticky interrupt flag, cleared by `irq_ack`, `clear_pulse`, or `start_pulse`
- `count_value`
  - current countdown value

## Behavioral Contract

- The timer counts down toward zero.
- `start_pulse` loads `load_value`, clears pending interrupt state, clears prescaler state, and starts the timer when `load_value != 0`.
- `load_pulse` loads `load_value` and clears prescaler state without changing running state.
- `stop_pulse` stops the timer and clears prescaler state without clearing the current count.
- `clear_pulse` clears count, running state, pending interrupt state, and prescaler state.
- Control priority is `clear_pulse` over `load_pulse` over `stop_pulse` over `start_pulse` over normal counting.
- The timer expires when a decrement tick occurs while `count_value == 1`.
- On expiration:
  - `expire_pulse` asserts for one cycle
  - `irq` sets when `irq_enable = 1`
  - if `periodic_en = 1` and `reload_value != 0`, the timer reloads `reload_value` and continues running
  - otherwise the timer stops and `count_value` becomes zero
- When `PRESCALE_WIDTH = 0`, the timer advances every clock.
- When `PRESCALE_WIDTH > 0`, the timer advances every `prescale_div + 1` clocks.

## Current Implementation Notes

- The current baseline is a countdown timer with direct start, stop, clear, load, periodic, and sticky interrupt behavior.
- `prescale_div` remains a visible port even when `PRESCALE_WIDTH = 0`; in that configuration it is ignored and should be tied low.
- Runtime reprogramming is deterministic because control priority is explicit and documented.

## Illegal Configurations

- `COUNT_WIDTH < 1`
- `PRESCALE_WIDTH < 0`

## Planned Future Expansion

- explicit capture or read-snapshot outputs
- optional elapsed-time mode alongside countdown mode
- optional interrupt pulse mode in addition to sticky interrupt mode
- wrapper variants aligned with bus-facing register banks
