# Glitchless Clock Switch Verification Plan

## Verification Goals

- Check reset selects the configured default source.
- Check ownership remains one-hot through all switching scenarios.
- Check handoff to the requested source eventually completes while both clocks are running.
- Check the switched output continues toggling from the currently granted source.
- Check the documented environment contract that `select_req` stays stable while `switch_busy` is asserted.

## Simulation Coverage

The first-pass simulation covers:

- default-source startup for source A and source B
- handoff from source A to source B
- handoff from source B back to source A
- one-hot ownership checking during all transitions
- switched-clock edge activity from both source clocks

## Formal Coverage

The first-pass formal harness checks reset-state and ownership public-contract invariants:

- reset grants only the configured default source
- reset makes `active_select_valid` high
- reset keeps `switch_busy` low
- reset keeps `switched_clk` low when both sources are held low
- ownership remains mutually exclusive
- `switch_busy` matches the public status contract
- the environment holds `select_req` stable while the switch is busy
