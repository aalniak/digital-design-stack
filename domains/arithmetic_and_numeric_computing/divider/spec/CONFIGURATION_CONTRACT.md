# Divider Configuration Contract

## Supported Baseline

The current `divider` implementation is a combinational exact integer divider with explicit divide-by-zero and signed-overflow policy.

Supported configuration knobs:

- `DATA_WIDTH >= 1`
- `SIGNED_MODE = 0 or 1`
- `RETURN_REMAINDER_EN = 0 or 1`
- `SATURATE_ON_OVERFLOW = 0 or 1`
- `DIVIDE_BY_ZERO_QUOTIENT_ONES = 0 or 1`

## Port Contract

Inputs:

- `dividend`: numerator input
- `divisor`: denominator input

Outputs:

- `quotient`: exact quotient under the configured policy
- `remainder`: exact remainder when enabled, otherwise zero
- `divide_by_zero`: asserted when `divisor = 0`
- `overflow`: asserted only on the signed most-negative divided by `-1` corner case

## Numeric Contract

Unsigned mode:

- `quotient = dividend / divisor`
- `remainder = dividend % divisor`

Signed mode:

- division follows standard truncation toward zero semantics
- remainder follows the sign of the dividend, matching the SystemVerilog signed `%` behavior

Special cases:

- divide by zero:
  - `divide_by_zero = 1`
  - `quotient` becomes either all ones or zero depending on `DIVIDE_BY_ZERO_QUOTIENT_ONES`
  - `remainder = dividend` before optional remainder suppression
- signed overflow case `SIGNED_MIN / -1`:
  - `overflow = 1`
  - if `SATURATE_ON_OVERFLOW = 1`, `quotient = SIGNED_MAX`
  - otherwise `quotient = SIGNED_MIN`
  - `remainder = 0`

## Important Current Choices

- the baseline is exact and combinational rather than iterative
- divide-by-zero and overflow handling are explicit policy decisions, not tool-dependent behavior
- remainder suppression zeros only the output port and does not change quotient or status behavior

## Unsupported Today

Not implemented in the current baseline:

- iterative start/busy/done handshake modes
- pipelined high-throughput variants
- fixed-point quotient scaling
- selectable signed remainder convention families beyond the current policy
