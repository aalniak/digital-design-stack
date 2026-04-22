# RTC Block Verification Plan

## Verification Goals

- Check reset clears RTC time and alarm status.
- Check prescaler-driven RTC increment behavior.
- Check alarm programming and pulse generation.
- Check alarm-pending clear behavior.
- Check set-time overrides the count path and realigns the prescaler.

## Simulation Coverage

The first-pass simulation covers:

- reset and idle behavior
- prescaled counting
- programmed alarm pulse and sticky pending status
- pending clear
- set-time and follow-on counting

## Formal Coverage

The first-pass formal harness checks public-contract invariants:

- reset clears time and alarm status
- `alarm_pulse` implies `alarm_pending`

The formal harness intentionally stays lightweight. It does not try to prove:

- exact prescaler timing under arbitrary control changes
- sampled-control relationships for `second_tick`
