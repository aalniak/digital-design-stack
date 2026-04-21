# Priority Arbiter Configuration Contract

## Implemented Configuration Surface

The current `priority_arbiter` implementation provides a reusable fixed-priority combinational arbitration primitive with the following parameter set:

- `NUM_REQUESTERS`
  - number of request inputs
  - legal range in the current implementation: `NUM_REQUESTERS >= 1`
- `LOW_INDEX_HIGH_PRIORITY`
  - priority-direction selector
  - `1` gives lower request index higher priority
  - `0` gives higher request index higher priority

## Ports

- `request`
  - active request vector
- `mask`
  - enable mask applied before arbitration
- `grant_onehot`
  - one-hot grant result
- `grant_valid`
  - indicates that at least one masked request is active
- `grant_index`
  - encoded winning requester index

## Behavioral Contract

- Arbitration is purely combinational in the current implementation.
- Only requests with the corresponding `mask` bit set may win.
- `grant_onehot` selects exactly one requester when `grant_valid = 1`.
- `grant_valid = 0` and `grant_onehot = 0` when no masked requests are active.
- `grant_index` matches the granted requester when `grant_valid = 1`.
- Priority ordering is deterministic and controlled by `LOW_INDEX_HIGH_PRIORITY`.

## Current Implementation Notes

- The current baseline does not include hold or lock state.
- The current baseline does not include programmable per-request priority tables.
- The encoded output is always present in this first implementation.

## Illegal Configurations

- `NUM_REQUESTERS < 1`

## Planned Future Expansion

- optional lock or hold-until-accept behavior
- programmable priority ordering beyond simple direction reversal
- multi-winner grant variants for banked resources
