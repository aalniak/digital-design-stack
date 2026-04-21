# Stream FIFO Verification Plan

## Verification Goals

- Check stored ordering across bursts, stalls, and simultaneous push or pop activity.
- Check full, empty, and watermark signaling against visible occupancy.
- Check full-rate replacement behavior when the FIFO is full and a consumer pop makes room in the same cycle.
- Check sideband alignment with payload through long randomized traffic.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-empty behavior
- directed fill, overflow, and drain sequences
- same-cycle replacement at full occupancy
- randomized push and pop traffic with scoreboard-based order checking
- occupancy and watermark checks after each visible state update

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset returns the FIFO to an empty visible state
- `m_valid` is low during reset
- `occupancy` is zero during reset
- `overflow` is low during reset

## Next Verification Expansions

- parameter sweep automation over multiple widths and depths
- stronger formal ordering proofs with a symbolic shadow queue
- read-during-write characterization for different future storage styles
