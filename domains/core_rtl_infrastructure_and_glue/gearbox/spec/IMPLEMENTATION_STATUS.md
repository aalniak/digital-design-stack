# Gearbox Implementation Status

## Current Status

`gearbox` is now implemented as the first general symbol-based repacking primitive in the core library.

The current implementation supports:

- same-clock valid-ready repacking
- arbitrary `SYMBOL_WIDTH`
- arbitrary `IN_SYMBOLS` to `OUT_SYMBOLS` ratios
- sparse ingress `s_keep` compaction into contiguous output lanes
- packet-boundary propagation through `s_last` when enabled
- explicit partial-drain control through `flush` when enabled

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for bypass behavior, widening preflush behavior, explicit flush drain, and narrowing compaction
- Yosys synthesis sanity
- SymbiYosys lightweight formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_gearbox_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The widening path favors explicit, inspectable behavior over zero-bubble throughput.
- Sparse `s_keep` masks are compacted rather than preserved lane-for-lane.
- The narrowing path accepts one ingress beat at a time and then drains it over one or more egress beats.
- `flush` is intentionally explicit so packet-close behavior is not inferred from silence or reset.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- asynchronous or dual-clock variants
- wrapper profiles that hide stable-but-optional ports for simpler interface presets
- randomized multi-ratio regressions
- deeper sequential formal proofs about symbol conservation and boundary placement
- zero-length packet handling

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Improve throughput behavior
   - add a buffered widening variant that can preflush and accept in the same cycle
   - add an optional registered output path for tougher timing corners

2. Expand configuration surface
   - add alignment-order options for applications that prefer high-lane-first packing
   - add wrapper profiles for common byte and packet conventions

3. Expand verification breadth
   - add randomized sparse-mask and ratio sweeps
   - add stronger formal checks for symbol conservation and `m_last` placement
