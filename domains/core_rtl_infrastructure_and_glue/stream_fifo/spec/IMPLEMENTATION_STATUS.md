# Stream FIFO Implementation Status

## Current Status

`stream_fifo` is implemented and verified as the baseline same-clock ready-valid buffering primitive for the core library.

The current implementation supports:

- configurable payload width through `DATA_WIDTH`
- optional beat-aligned metadata through `SIDEBAND_WIDTH`
- configurable storage depth through `DEPTH`
- occupancy and watermark signaling
- same-cycle full-rate replacement when a pop and push happen together at full occupancy
- stable public porting with optional occupancy suppression through `COUNT_EN`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation with directed overflow and replacement cases
- randomized simulation with scoreboard-based ordering checks
- Yosys synthesis sanity
- SymbiYosys lightweight formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_stream_fifo_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The current baseline is intentionally same-clock only.
- Output timing is the direct unregistered head-of-queue view.
- `overflow` is a pulse rather than a sticky diagnostic.
- The module allows an ingress beat to replace a consumed beat in the same cycle when full.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- registered-output mode through `OUTPUT_REG = 1`
- first-word-fall-through versus registered-output family variants
- explicit underflow diagnostics
- broader parameter sweep automation across many more widths and depths
- deeper formal proofs that connect a symbolic history directly to stored ordering
- broader sequential invariant proofs beyond reset-state behavior

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Grow the family
   - add registered-output and first-word-fall-through variants without destabilizing the baseline interface
   - add packet-aware wrappers for common framing sidebands

2. Expand verification breadth
   - sweep more depths and sideband widths
   - add stronger ordering properties with lightweight shadow modeling

3. Improve system integration support
   - add optional underflow diagnostics and standardized status wrappers
