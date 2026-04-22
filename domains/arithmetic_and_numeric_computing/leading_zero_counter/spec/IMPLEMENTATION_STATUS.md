# Leading Zero Counter Implementation Status

## Current Status

`leading_zero_counter` is implemented as a reusable normalization helper with an explicit all-zero policy and optional highest-set-bit index output.

The current implementation supports:

- most-significant-side zero counting
- explicit `all_zero` reporting
- width-return count behavior on an all-zero input
- optional highest-set-bit index reporting

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for zero input, top-bit hit, interior-bit hit, lowest-bit hit, and index suppression behavior
- Yosys synthesis sanity
- SymbiYosys exact combinational proof for a small instance

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_leading_zero_counter_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- all-zero input returns a count equal to `DATA_WIDTH`
- `msb_index` reports the highest set bit, not the first zero after the run
- index suppression zeros the index output without altering count or flag behavior
- the baseline is purely combinational

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- pipelined variants for large-width timing closure
- selectable all-zero return policy
- one-hot or encoded priority outputs beyond `msb_index`
- trailing-zero mode

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
