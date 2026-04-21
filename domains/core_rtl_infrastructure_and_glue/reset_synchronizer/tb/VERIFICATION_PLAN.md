# Reset Synchronizer Verification Plan

## Verification Goals

- Prove that reset assertion follows the configured assertion mode.
- Prove that reset release is synchronized to `clk`.
- Check that release latency matches `STAGES` in the exercised configurations.
- Check polarity handling for both active-low and active-high instances.
- Check that `release_done` tracks the fully released state.

## Simulation Coverage

The first-pass simulation covers:

- active-low asynchronous assertion instance
- active-high synchronous assertion instance
- asynchronous deassertion between clock edges
- exact release latency counting
- reassertion after release

## Formal Coverage

The first-pass formal harness proves selected public-contract invariants for the active-low asynchronous-assert configuration:

- asserted input forces asserted local reset
- `release_done` is never high while local reset is asserted
- `release_done` only appears when local reset is deasserted

## Next Verification Expansions

- add parameter sweep automation over `STAGES`
- add a second formal harness for active-high operation
- add environment-constrained proofs around release latency bounds
- add synthesis-flow checks for preservation attributes when vendor wrappers are introduced
