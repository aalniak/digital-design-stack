# Round Robin Arbiter Configuration Contract

## Implemented Configuration Surface

The current `round_robin_arbiter` implementation provides a reusable fairness-oriented arbitration primitive with the following parameter set:

- `NUM_REQUESTERS`
  - number of request inputs
  - legal range in the current implementation: `NUM_REQUESTERS >= 1`

## Ports

- `clk`
  - local arbitration clock
- `rst_n`
  - active-low reset
- `request`
  - active request vector
- `mask`
  - enable mask applied before arbitration
- `advance`
  - pointer-advance event, typically driven by acceptance of the current grant
- `grant_onehot`
  - one-hot grant result
- `grant_valid`
  - indicates that at least one masked request is active
- `grant_index`
  - encoded winning requester index

## Behavioral Contract

- Arbitration scans masked requests beginning at the current round-robin pointer.
- Lower offsets from the current pointer have higher priority for the current arbitration result.
- `grant_onehot` selects exactly one requester when `grant_valid = 1`.
- `grant_valid = 0` and `grant_onehot = 0` when no masked requests are active.
- `grant_index` matches the granted requester when `grant_valid = 1`.
- The round-robin pointer advances only when `advance = 1` and `grant_valid = 1`.
- On advance, the next pointer position becomes the requester immediately after the granted requester, with wraparound.
- Reset initializes the pointer to requester index `0`.

## Current Implementation Notes

- The current baseline has a single fairness pointer and one grant per cycle.
- The current baseline does not implement park mode or hold-until-end semantics.
- Masking affects eligibility but does not alter pointer state directly.

## Illegal Configurations

- `NUM_REQUESTERS < 1`

## Planned Future Expansion

- optional hold semantics for multi-cycle ownership
- programmable idle park behavior
- hierarchical variants for very wide requester counts
