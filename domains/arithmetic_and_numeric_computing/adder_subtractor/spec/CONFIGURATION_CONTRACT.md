# Adder Subtractor Configuration Contract

## Implemented Configuration Surface

The current `adder_subtractor` baseline provides a combinational add or subtract primitive with the following parameters:

- `DATA_WIDTH`
  - operand and result width
  - legal values: integers `>= 1`
- `SIGNED_MODE`
  - enables signed overflow and negative-flag semantics
  - legal values: `0` or `1`
- `CARRY_IN_EN`
  - enables use of `carry_in` during addition
  - legal values: `0` or `1`

## Ports

- `operand_a`
  - first arithmetic operand
- `operand_b`
  - second arithmetic operand
- `add_sub`
  - `0` selects addition, `1` selects subtraction
- `carry_in`
  - optional carry input for addition when `CARRY_IN_EN = 1`
- `result`
  - arithmetic result
- `carry_out`
  - carry out for addition or not-borrow indication for subtraction
- `overflow`
  - signed overflow flag when `SIGNED_MODE = 1`
- `zero`
  - result-is-zero flag
- `negative`
  - sign flag when `SIGNED_MODE = 1`

## Behavioral Contract

- Addition computes `operand_a + operand_b + carry_in` when `CARRY_IN_EN = 1`.
- Subtraction computes `operand_a - operand_b` using a two's-complement subtract path.
- `carry_in` is ignored in subtraction mode in the current baseline.
- `carry_out` is the carry bit for addition and the no-borrow indicator for subtraction.
- `overflow` is only meaningful when `SIGNED_MODE = 1`.

## Current Implementation Notes

- This baseline is purely combinational and unpipelined.
- The block does not implement saturation.
- Signed and unsigned interpretation only affects flags, not the raw bit-level result.

## Illegal Configurations

- `DATA_WIDTH < 1`
- `SIGNED_MODE` not in `{0, 1}`
- `CARRY_IN_EN` not in `{0, 1}`

## Planned Future Expansion

- optional borrow-in behavior for subtract chaining
- pipelined wrapper profiles
- optional saturation mode through a separate wrapper
