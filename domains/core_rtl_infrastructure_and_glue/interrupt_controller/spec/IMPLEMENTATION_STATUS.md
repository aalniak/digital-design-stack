# Interrupt Controller Implementation Status

## Current Status

`interrupt_controller` is implemented and verified as the reusable fixed-priority interrupt aggregation primitive for control-plane event fan-in.

The current implementation supports:

- configurable source count through `NUM_SOURCES`
- per-source edge-versus-level mode selection
- per-source enable masking
- sticky edge-latched pending state
- software-set pending injection
- vector output through `irq_id`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- directed edge-source pending simulation
- directed level-source re-service simulation
- simultaneous-event priority simulation
- masked-pending accumulation simulation
- software-set and acknowledge simulation
- Yosys synthesis sanity
- SymbiYosys formal proof of reset-safety and selection-consistency invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_interrupt_controller_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- Priority is fixed with lower source index winning.
- Edge-mode sources are sticky until acknowledged.
- Level-mode requests are not suppressible by acknowledge while the source remains asserted.
- `enable_mask` only affects delivery, not pending capture.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- programmable priority ordering
- active-in-service or claim-complete handshake state
- multi-output or target-group routing
- automated parameter sweeps across larger source counts
- deeper formal proofs around simultaneous acknowledge and level-source interactions

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Expand verification breadth
   - add parameter sweeps over source count
   - add stronger formal properties around priority and ack races

2. Grow the family shape
   - add hierarchical or multi-target variants
   - add software-friendly claim-complete wrappers

3. Improve integration visibility
   - add raw, masked, and serviced status views aligned with software register maps
