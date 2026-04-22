# Clock Mux Controller Verification Plan

## Verification Goals

- Check reset chooses the configured default source and clears progress state.
- Check manual requests wait for stable target health before switching when enabled.
- Check invalid or inhibited manual requests pulse rejection without corrupting state.
- Check automatic failover chooses a healthy alternate source when the active source fails.
- Check fault reporting asserts when no healthy source is available.
- Check sticky status clear behavior.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-default behavior
- manual request held pending until target health becomes stable
- successful switch commit with post-switch hold window
- invalid source index rejection
- inhibit-switch manual rejection
- automatic failover from an unhealthy active source
- fault assertion when no healthy source remains
- sticky status clear behavior

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset selects `DEFAULT_SOURCE`
- reset clears pending and progress state
- reset clears pulse outputs
- reset suppresses `active_source_healthy`, `fault_status`, and `auto_failover_status`

## Next Verification Expansions

- randomized request and health toggling scenarios
- proofs for manual-request priority over auto failover
- proofs for deterministic alternate-source selection
- longer checks around hold-window accounting and pulse exclusivity
