# Stream Mux Verification Plan

## Verification Goals

- Check that only the granted ingress sees `ready`.
- Check priority and round-robin arbitration pick the correct input.
- Check hold mode prevents mid-packet source switching.
- Check reset clears held state and suppresses output traffic.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-idle behavior
- fixed-priority selection and backpressure routing
- round-robin rotation across multiple requesting inputs
- held packet routing across multiple beats even when other inputs request service

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset forces `m_valid` low
- reset clears `held_grant_active`
- reset drives all ingress `ready` signals low

## Next Verification Expansions

- randomized contention and packet-length mixes
- stronger formal checks for round-robin pointer movement
- explicit violation tests for dropping a held packet source mid-flight
