# Packetizer Verification Plan

## Verification Goals

- Check reset suppresses framed output and clears status.
- Check sideband-only framing produces the expected first and last markers.
- Check malformed ingress sequencing sets `protocol_error` deterministically.
- Check header mode inserts exactly one synthetic header beat and then replays the held first payload beat.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-idle behavior
- sideband-only packet emission with metadata reuse across a multi-beat packet
- missing-`s_first` detection at packet start
- header-beat encoding and insertion
- held-first-payload replay and continued payload emission in header mode

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset forces `m_valid` low
- reset forces `busy` low
- reset drives `s_ready` low
- reset clears `protocol_error`

## Next Verification Expansions

- randomized packet-length and restart-sequencing mixes
- cross-checking header data encoding against a scoreboard model
- deeper formal checks around held-payload state and packet restart behavior
