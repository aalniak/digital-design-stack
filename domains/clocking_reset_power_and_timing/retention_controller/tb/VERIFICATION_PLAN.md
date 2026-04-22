# Retention Controller Verification Plan

## Verification Goals

- Check reset clears busy state and retained-context validity.
- Check a qualified save request emits a save pulse and latches retained-context validity on completion.
- Check a qualified restore request emits a restore pulse and clears retained-context validity on completion.
- Check restore timeout latches a sticky fault.
- Check fault clear while idle re-enables operation.

## Simulation Coverage

The first-pass simulation covers:

- reset and idle behavior
- save success
- restore success
- restore timeout fault path
- fault clear and successful retry

## Formal Coverage

The first-pass formal harness checks public-contract invariants:

- reset clears busy state, pulses, and retained-context validity
- `busy` implies the controller is not in idle state
- `restore_pulse` only occurs when retained context is valid

The formal harness intentionally stays lightweight. It does not try to prove:

- exact save or restore timeout latency
- every request-blocking corner under simultaneous control changes
