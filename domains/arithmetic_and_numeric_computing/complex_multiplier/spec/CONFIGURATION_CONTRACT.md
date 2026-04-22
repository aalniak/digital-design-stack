# Complex Multiplier Configuration Contract

## Supported Baseline

The current `complex_multiplier` implementation is a combinational complex-product primitive with optional conjugation of operand B.

Supported configuration knobs:

- `DATA_WIDTH >= 1`
- `SIGNED_MODE = 0 or 1`

## Port Contract

Inputs:

- `operand_a_re`, `operand_a_im`: real and imaginary components of operand A
- `operand_b_re`, `operand_b_im`: real and imaginary components of operand B
- `conjugate_b`: when asserted, the imaginary component of operand B is negated in fixed width before multiplication

Outputs:

- `product_re`: real component of the complex product
- `product_im`: imaginary component of the complex product

Output width is `2 * DATA_WIDTH + 1` to preserve the extra bit required by the final add or subtract stage.

## Numeric Contract

The baseline implements:

- `product_re = (a_re * b_re) - (a_im * b_im_eff)`
- `product_im = (a_re * b_im_eff) + (a_im * b_re)`

where `b_im_eff` is either `operand_b_im` or its fixed-width two's-complement negation when `conjugate_b = 1`.

## Important Current Choices

- conjugation is applied in fixed input width, so the most-negative signed value follows normal fixed-width wrap behavior
- `SIGNED_MODE = 1` interprets all components as signed two's-complement values
- `SIGNED_MODE = 0` interprets all input components as unsigned values, while the recombined outputs still use the signed-capable widened output format
- the baseline is combinational and has no valid-handshake shell

## Unsupported Today

Not implemented in the current baseline:

- reduced-multiplier architectures
- pipelined latency options
- explicit narrowing or rounding modes
- per-lane overflow or saturation flags
