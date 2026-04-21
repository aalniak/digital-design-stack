# Reset Synchronizer Configuration Contract

## Implemented Configuration Surface

The current `reset_synchronizer` implementation provides a reusable local-reset release primitive with the following parameter set:

- `STAGES`
  - number of synchronization stages used for reset release
  - legal range in the current implementation: `STAGES >= 2`
- `ACTIVE_LOW`
  - `1` means the incoming and outgoing resets are active low
  - `0` means the incoming and outgoing resets are active high
- `ASYNC_ASSERT`
  - `1` means reset assertion is immediate and asynchronous to `clk`
  - `0` means both assertion and deassertion are synchronized to `clk`

## Ports

- `clk`
  - destination-domain clock that governs reset release
- `rst_in`
  - upstream reset input in the selected polarity
- `rst_out`
  - locally synchronized reset output in the selected polarity
- `release_done`
  - high when the synchronized local reset has fully deasserted

## Behavioral Contract

- `rst_out` must assert according to the selected `ASYNC_ASSERT` policy.
- `rst_out` must deassert only after the configured number of destination clock edges has advanced the internal release chain.
- `release_done` must remain low while local reset is asserted.
- `release_done` must become high only after local reset has fully deasserted.
- Each clock domain must use its own `reset_synchronizer` instance.

## Current Implementation Notes

- The current RTL normalizes reset polarity internally and drives a shift register of asserted-state bits.
- The implemented feature set is intentionally compact so the reset contract remains easy to prove and reuse.
- Optional done-port removal, test-mode bypass, and vendor-specific attributes are not yet parameterized.

## Illegal Configurations

- `STAGES < 2`

## Planned Future Expansion

- optional explicit synchronizer attributes per vendor flow
- optional bypass for already-synchronous reset sources
- optional test or scan override behavior
- optional external `release_pulse` or staged-release variants
