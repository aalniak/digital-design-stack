# RTC Block Configuration Contract

## Implemented Configuration Surface

The current `rtc_block` baseline provides a small always-on real-time counter with the following parameters:

- `COUNTER_WIDTH`
  - width of the RTC time and alarm registers
  - legal values: integers `>= 1`
- `PRESCALE_CYCLES`
  - number of `clk` cycles per RTC time increment
  - legal values: integers `>= 1`

## Ports

- `clk`
  - always-on RTC reference clock
- `rst_n`
  - active-low reset
- `enable`
  - enables prescaled RTC counting
- `set_time`
  - synchronously loads `set_time_value` into the RTC counter
- `set_time_value`
  - new RTC time value
- `set_alarm`
  - synchronously loads and enables the alarm value
- `alarm_value_in`
  - new alarm compare value
- `clear_alarm_pending`
  - clears sticky alarm-pending status
- `rtc_time`
  - current RTC time counter
- `alarm_value`
  - currently programmed alarm value
- `alarm_enabled`
  - indicates an alarm value is armed
- `second_tick`
  - one-cycle pulse when the prescaler advances RTC time by one count
- `alarm_pulse`
  - one-cycle pulse when the RTC time equals the programmed alarm
- `alarm_pending`
  - sticky alarm status until cleared

## Behavioral Contract

- `set_time` has priority over prescaled counting.
- RTC time increments by one each time the prescaler expires while `enable = 1`.
- `set_alarm` loads a new alarm value and enables alarm comparison.
- `alarm_pulse` and `alarm_pending` assert when the next visible RTC time equals the programmed alarm.
- `clear_alarm_pending` clears the sticky alarm flag without disabling the alarm.

## Current Implementation Notes

- The baseline is a generic counter-based RTC primitive rather than a calendar date/time block.
- The alarm remains enabled after it fires.
- `second_tick` is named as a generic RTC tick; actual wall-clock meaning depends on `PRESCALE_CYCLES` and `clk`.

## Illegal Configurations

- `COUNTER_WIDTH < 1`
- `PRESCALE_CYCLES < 1`

## Planned Future Expansion

- multiple alarms
- periodic alarm modes
- calendar conversion or BCD timekeeping wrappers
