# Barrel Shifter Configuration Contract

## Supported Baseline

The current `barrel_shifter` implementation is a combinational variable-shift primitive with four fixed modes and optional sticky-bit reporting.

Supported configuration knobs:

- `DATA_WIDTH >= 1`
- `AMOUNT_WIDTH >= 1`
- `STICKY_BIT_EN = 0 or 1`

## Port Contract

Inputs:

- `data_in`: source word to shift or rotate
- `shift_amount`: shift count in the configured width
- `shift_mode`: 2-bit mode select

Mode encoding:

- `2'b00`: logical left shift
- `2'b01`: logical right shift
- `2'b10`: arithmetic right shift
- `2'b11`: rotate left

Outputs:

- `data_out`: shifted or rotated result
- `sticky`: OR-reduction of shifted-out bits for non-rotate modes when `STICKY_BIT_EN = 1`, otherwise zero

## Boundary Semantics

For non-rotate modes:

- shift counts greater than or equal to `DATA_WIDTH` are treated as oversize shifts
- logical left and logical right oversize shifts produce zero
- arithmetic right oversize shifts produce all sign bits
- sticky reports whether any discarded bit was high

For rotate-left mode:

- the effective rotate count is `shift_amount % DATA_WIDTH`
- rotate mode never asserts sticky in the current baseline

## Important Current Choices

- the baseline supports rotate-left but not rotate-right
- oversize shift counts are explicitly defined rather than left to tool-dependent behavior
- sticky reports discarded information, not fill bits
- the baseline is combinational and has no valid-handshake shell

## Unsupported Today

Not implemented in the current baseline:

- rotate-right mode
- arithmetic left shift mode
- pipelined latency options
- shifted-out bus export beyond the single sticky bit
