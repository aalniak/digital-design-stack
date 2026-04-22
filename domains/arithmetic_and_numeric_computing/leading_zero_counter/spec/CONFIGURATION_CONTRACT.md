# Leading Zero Counter Configuration Contract

## Supported Baseline

The current `leading_zero_counter` implementation is a combinational priority-detect primitive that counts zeros from the most-significant end of the word.

Supported configuration knobs:

- `DATA_WIDTH >= 1`
- `RETURN_MSB_INDEX_EN = 0 or 1`

## Port Contract

Inputs:

- `data_in`: source word to inspect from MSB toward LSB

Outputs:

- `leading_zero_count`: number of consecutive zeros before the highest set bit
- `all_zero`: asserted when the input word contains no set bits
- `msb_index`: index of the highest set bit, or zero when `RETURN_MSB_INDEX_EN = 0` or when `all_zero = 1`

## Zero-Input Policy

The current baseline uses the explicit width-return policy for an all-zero input.

That means:

- `all_zero = 1`
- `leading_zero_count = DATA_WIDTH`
- `msb_index = 0`

## Important Current Choices

- counting starts at the most-significant bit and proceeds toward the least-significant bit
- the baseline returns the highest set-bit index rather than a one-hot mask
- index reporting can be suppressed without changing count behavior
- the baseline is combinational and has no valid-handshake shell

## Unsupported Today

Not implemented in the current baseline:

- one-hot or thermometer-style position outputs
- pipelined latency options
- configurable all-zero count policy
- trailing-zero counting in the same module
