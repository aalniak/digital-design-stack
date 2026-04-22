# Saturating Adder Configuration Contract

## Supported Baseline

The current `saturating_adder` implementation is a combinational bounded-add primitive for fixed-width signed or unsigned arithmetic.

Supported configuration knobs:

- `DATA_WIDTH >= 1`
- `SIGNED_MODE = 0 or 1`
- `CARRY_IN_EN = 0 or 1`
- `CUSTOM_LIMITS_EN = 0 or 1`
- `FLAG_EN = 0 or 1`

## Port Contract

Inputs:

- `operand_a`, `operand_b`: same-width operands
- `carry_in`: optional single-bit increment term used only when `CARRY_IN_EN = 1`
- `custom_min_limit`, `custom_max_limit`: active only when `CUSTOM_LIMITS_EN = 1`

Outputs:

- `result`: clipped or unclipped sum
- `saturated`: asserted when clipping occurs and `FLAG_EN = 1`
- `at_min`: asserted when clipping hits the minimum bound and `FLAG_EN = 1`
- `at_max`: asserted when clipping hits the maximum bound and `FLAG_EN = 1`

## Mathematical Contract

The implementation computes a widened mathematical sum and then clips it to the active legal range.

Active range selection:

- signed mode default range: `[-2^(DATA_WIDTH-1), 2^(DATA_WIDTH-1)-1]`
- unsigned mode default range: `[0, 2^DATA_WIDTH-1]`
- when `CUSTOM_LIMITS_EN = 1`, the custom limit ports replace the default bounds

For signed mode, custom limits are interpreted as two's-complement signed values.

## Important Current Choices

- clipping flags report clipping, not native carry behavior
- `carry_in` is modeled as a positive one-bit increment term
- custom limit ordering must be valid for the chosen numeric interpretation
- the baseline has no pipelining or valid-handshake shell

## Unsupported Today

Not implemented in the current baseline:

- runtime error reporting for invalid custom limit ordering
- separate raw overflow or raw widened-sum outputs
- pipelined latency options
- subtract or accumulate modes
