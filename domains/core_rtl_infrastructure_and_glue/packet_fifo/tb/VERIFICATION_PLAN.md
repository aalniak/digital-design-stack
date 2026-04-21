# Packet FIFO Verification Plan

## Verification Goals

- Check beat order, metadata, and packet boundaries survive buffering.
- Check `packet_occupancy` counts complete packets rather than partial packets.
- Check backpressure and overflow behavior remain aligned with the wrapped `stream_fifo`.
- Check partial packets do not corrupt later packet accounting.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-empty behavior
- directed partial-packet occupancy checks
- directed multi-packet traffic with variable packet lengths
- randomized push and pop traffic with a packet-aware scoreboard
- beat-level and packet-level occupancy checks after each visible state update

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset returns the FIFO to an empty visible state
- `m_valid` is low during reset
- `beat_occupancy` is zero during reset
- `packet_occupancy` is zero during reset
- `overflow` is low during reset

## Next Verification Expansions

- stronger sequential formal checks for packet-count evolution
- parameter sweep automation across widths, depths, and packet-length mixes
- malformed-packet stress tests with explicit policy assertions
