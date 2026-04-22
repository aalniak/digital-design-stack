# Multiplier Configuration Contract

## Supported Baseline

The current `multiplier` implementation is a combinational product primitive with exact full-product generation and configurable output slicing.

Supported configuration knobs:

- `A_WIDTH >= 1`
- `B_WIDTH >= 1`
- `SIGNED_MODE = 0 or 1`
- `1 <= OUTPUT_WIDTH <= A_WIDTH + B_WIDTH`
- `SELECT_HIGH_SLICE = 0 or 1`

## Port Contract

Inputs:

- `operand_a`: multiplicand input
- `operand_b`: multiplier input

Outputs:

- `product_out`: selected contiguous slice of the full product
- `discarded_nonzero`: asserted when any bits outside the reported slice are nonzero

## Numeric Contract

The baseline computes the exact full-width product first.

- full product width is `A_WIDTH + B_WIDTH`
- `SIGNED_MODE = 1` interprets both operands as signed two's-complement values
- `SIGNED_MODE = 0` interprets both operands as unsigned values

Slice policy:

- `SELECT_HIGH_SLICE = 0`: `product_out` returns the least-significant `OUTPUT_WIDTH` bits
- `SELECT_HIGH_SLICE = 1`: `product_out` returns the most-significant `OUTPUT_WIDTH` bits

## Important Current Choices

- the module always computes the full product internally before selecting the exported slice
- `discarded_nonzero` reports information loss outside the exported slice, not arithmetic overflow in a separate numeric sense
- the baseline is combinational and has no valid-handshake shell
- there is no rounding policy in the current baseline; slicing is direct bit selection

## Unsupported Today

Not implemented in the current baseline:

- rounded narrowing modes
- pipelined latency options
- mixed signedness between `operand_a` and `operand_b`
- simultaneous export of both full and narrowed products
