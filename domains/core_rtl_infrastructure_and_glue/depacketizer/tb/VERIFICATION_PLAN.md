# Depacketizer Verification Plan

## Verification Goals

- Check reset suppresses payload output and clears parser state.
- Check sideband mode normalizes packet boundaries and preserves metadata.
- Check malformed sequencing sets `protocol_error` deterministically.
- Check header mode decodes metadata correctly and strips the header beat from payload output.
- Check `DROP_BAD_PACKET` suppresses payload without corrupting parser recovery.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-idle behavior
- sideband parsing with sticky protocol-error behavior on a missing `s_first`
- sideband metadata reuse across a multi-beat packet
- header-beat decode and payload re-labeling
- header metadata mismatch detection
- bad-packet suppression in header mode when the decoded error flag is set

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset forces `m_valid` low
- reset forces `busy` low
- reset drives `s_ready` low
- reset clears `protocol_error`
- reset clears `dropping_packet`

## Next Verification Expansions

- randomized malformed-header and mid-packet mismatch scenarios
- tighter scoreboarding for payload-count and length agreement
- deeper formal checks for state recovery after dropped packets
