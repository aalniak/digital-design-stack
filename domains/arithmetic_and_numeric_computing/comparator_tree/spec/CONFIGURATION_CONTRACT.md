# Comparator Tree Configuration Contract

## Supported Baseline

The current `comparator_tree` implementation is a combinational reduction primitive that selects one winner from a masked set of candidate values.

Supported configuration knobs:

- `NUM_INPUTS >= 1`
- `DATA_WIDTH >= 1`
- `SIGNED_MODE = 0 or 1`
- `SELECT_MAX = 0 or 1`
- `RETURN_INDEX_EN = 0 or 1`

## Port Contract

Inputs:

- `candidates_flat`: packed candidate vector with candidate `i` stored in `candidates_flat[i*DATA_WIDTH +: DATA_WIDTH]`
- `candidate_valid`: mask indicating which candidates participate in the reduction

Outputs:

- `any_valid`: asserted when at least one candidate is selected into the reduction
- `winner_value`: selected winner value or zero when no input is valid
- `winner_index`: selected winner index, or zero when `RETURN_INDEX_EN = 0` or when no input is valid

## Selection Contract

The module performs a linear reduction over the valid candidates.

Selection policy:

- `SELECT_MAX = 1`: choose the numerically greatest valid candidate
- `SELECT_MAX = 0`: choose the numerically smallest valid candidate
- `SIGNED_MODE` controls whether candidates are interpreted as signed or unsigned values
- ties are resolved deterministically in favor of the lowest input index

## Important Current Choices

- the baseline is combinational rather than pipelined
- invalid candidates are fully ignored by the selection logic
- when no candidates are valid, the outputs are zeroed and `any_valid = 0`
- `RETURN_INDEX_EN = 0` suppresses the index output without changing value selection

## Unsupported Today

Not implemented in the current baseline:

- registered or pipelined tree stages
- auxiliary metadata forwarding beyond the winner index
- separate less-than or equal compare sideband outputs
- internal balanced-tree staging for timing optimization
