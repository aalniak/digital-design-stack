# Gearbox Verification Plan

## Verification Goals

- Check that reset suppresses output traffic and internal busy state.
- Check bypass behavior when ingress and egress symbol grouping matches.
- Check widening behavior for full groups, explicit flush drains, and preflush before overflow.
- Check narrowing behavior for sparse-mask compaction and partial final slices.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-idle behavior
- direct bypass handshaking
- widening with a forced preflush bubble before a larger next beat
- widening with a standalone explicit flush
- narrowing with sparse `s_keep` compaction and partial final output keep

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset forces `m_valid` low
- reset forces `busy` low
- reset drives `s_ready` low

## Next Verification Expansions

- randomized ratio sweeps across multiple symbol widths
- scoreboarding for symbol conservation across long packet streams
- deeper formal checks around packet-boundary placement and flush behavior
