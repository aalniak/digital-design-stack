# PLL Lock Monitor Verification Plan

## Verification Goals

- Check raw-lock chatter does not assert `filtered_lock` early.
- Check `stable_ready` never asserts before the configured relock holdoff expires.
- Check short loss glitches can drop `stable_ready` without immediately clearing `filtered_lock`.
- Check qualified loss produces `lock_lost_pulse` and `sticky_loss`.
- Check bypass-for-ready behavior when `BYPASS_EN = 1`.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-not-ready behavior
- assertion chatter rejection
- qualified lock acquisition
- relock holdoff timing
- single-cycle bad-sample behavior versus filtered loss
- sticky-loss set and clear behavior
- bypass override behavior

## Formal Coverage

The first-pass formal harness checks public-contract invariants:

- reset keeps all ready and pulse outputs low
- bypass-for-ready forces both `filtered_lock` and `stable_ready`
- `holdoff_active` never coexists with `stable_ready`
- `qualifying` only appears while monitoring is enabled
- lock-acquired and lock-lost pulses never assert together
