# Power Domain Controller Verification Plan

## Verification Goals

- Check powered-off reset behavior is conservative and quiet.
- Check power-up requires stable `power_good` before entering active operation.
- Check retained context causes a restore step before activation.
- Check power-off from `ACTIVE` requests save and then powers the domain down safely.
- Check save and restore timeouts latch a sticky fault and return the domain to a safe state.

## Simulation Coverage

The first-pass simulation covers:

- reset to powered-off state
- clean power-up without retained context
- retention save on shutdown and retained restore on next power-up
- restore timeout fault path
- fault clear and successful retry

## Formal Coverage

The first-pass formal harness checks public-contract invariants:

- reset keeps the controller in a safe powered-off posture
- `domain_active` implies the domain is powered, unisolated, ungated, and out of reset
- when power is removed, the safe shutdown controls remain asserted
- a restore pulse only occurs when retained context is marked valid

The formal harness intentionally stays lightweight. It does not try to prove:

- exact timeout latencies
- every multi-cycle transition sequence end to end
- analog behavior behind `power_good`
