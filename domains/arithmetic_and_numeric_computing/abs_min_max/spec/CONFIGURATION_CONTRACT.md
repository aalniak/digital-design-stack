# Abs Min Max Configuration Contract

## Supported Baseline

The current `abs_min_max` implementation is a combinational arithmetic helper that computes absolute value for `operand_a` and compare-select results for `operand_a` and `operand_b`.

Supported configuration knobs:

- `DATA_WIDTH >= 1`
- `SIGNED_MODE = 0 or 1`
- `SATURATE_ABS = 0 or 1`

## Port Contract

Inputs:

- `operand_a`: source for the absolute-value path and one compare operand
- `operand_b`: second compare operand

Outputs:

- `abs_a`: absolute value result for `operand_a` under the configured policy
- `min_value`, `max_value`: ordered pair of the two operands under the configured numeric interpretation
- `a_eq_b`: raw equality between the operands
- `a_lt_b`: compare result under the configured numeric interpretation
- `abs_saturated`: asserted only when the signed most-negative value is clipped because `SATURATE_ABS = 1`

## Numeric Contract

Comparison policy:

- `SIGNED_MODE = 1`: min, max, and `a_lt_b` use signed two's-complement ordering
- `SIGNED_MODE = 0`: min, max, and `a_lt_b` use unsigned ordering

Absolute-value policy:

- `SIGNED_MODE = 0`: `abs_a` passes through `operand_a`
- `SIGNED_MODE = 1` and `operand_a` is non-negative: `abs_a = operand_a`
- `SIGNED_MODE = 1` and `operand_a` is negative but not the most-negative value: `abs_a = -operand_a`
- `SIGNED_MODE = 1` and `operand_a` is the most-negative value:
  - if `SATURATE_ABS = 1`, `abs_a` clips to the maximum positive representable value and `abs_saturated = 1`
  - if `SATURATE_ABS = 0`, `abs_a` remains unchanged and `abs_saturated = 0`

## Important Current Choices

- ties preserve the original operand values, which means equal operands produce identical `min_value` and `max_value`
- the baseline computes `abs` only for `operand_a`
- the baseline is combinational and has no valid-handshake shell

## Unsupported Today

Not implemented in the current baseline:

- dual absolute-value outputs
- pipelined latency options
- configurable tie metadata or winner index
- separate magnitude compare outputs beyond the provided flags
