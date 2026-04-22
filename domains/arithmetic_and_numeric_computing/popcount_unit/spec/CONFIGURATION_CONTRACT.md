# Popcount Unit Configuration Contract

## Supported Baseline

The current `popcount_unit` implementation is a combinational total-count primitive for a single bit vector.

Supported configuration knobs:

- `DATA_WIDTH >= 1`
- `RETURN_FLAGS_EN = 0 or 1`

## Port Contract

Inputs:

- `data_in`: source bit vector to count

Outputs:

- `count_out`: exact number of set bits in `data_in`
- `is_zero`: asserted when no bits are set, or forced low when `RETURN_FLAGS_EN = 0`
- `is_full`: asserted when all bits are set, or forced low when `RETURN_FLAGS_EN = 0`

## Important Current Choices

- the baseline returns the exact total count with width `clog2(DATA_WIDTH + 1)`
- the input is interpreted as a pure bit field rather than as a signed or unsigned number
- flag suppression does not alter the count output
- the baseline is combinational and has no valid-handshake shell

## Unsupported Today

Not implemented in the current baseline:

- segmented sub-count outputs
- saturating or truncated count modes
- pipelined reduction stages
- sideband mask statistics beyond zero and full flags
