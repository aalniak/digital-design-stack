# Configurable Interface Guidelines

## Why This Exists

The library is being built around reusable IP blocks that may need to look different at the boundary depending on the project. Some users will want a bare native FIFO interface, some will want `valid/ready`, some will want packet sidebands, and some will want extra observability ports such as level counts or watermark flags.

That flexibility is valuable, but it becomes dangerous if port reconfiguration is handled in an ad hoc way. A module family that changes visible ports without a clear contract is difficult to integrate, harder to lint, and even harder to verify across its legal configuration space.

This document defines the preferred pattern for making modules configurable "by ports and stuff" without turning them into brittle monoliths.

## Preferred Design Pattern

Treat each reusable block as a module family with three layers:

1. Stable algorithmic core
   - Holds the state machine, arithmetic, buffering, CDC, or datapath logic.
   - Uses a stable internal port contract so its behavior can be reasoned about and verified once.

2. Thin interface wrappers
   - Adapt the stable core to different public-facing protocols or sideband profiles.
   - Expose only the ports needed for a chosen profile instead of forcing one giant superset port list on every integrator.

3. Optional SystemVerilog interfaces or packages
   - Useful when a project wants strong type grouping or shared parameter bundles.
   - Should remain optional because not every downstream environment wants SV interfaces in the synthesis or verification flow.

## What To Avoid

- One giant module whose ports only "sort of matter" depending on parameter values.
- Parameters that silently disable protocol obligations without changing documentation.
- Optional ports that are always present but become meaningless in half the configurations.
- Reusing the same port names to mean different handshake rules in different profiles.

These patterns make module integration ambiguous and verification coverage nearly impossible to trust.

## Recommended Types Of Configuration Knobs

### Structural knobs

Use these when the internal implementation legitimately changes:

- data width
- depth
- lane count
- feature widths such as `USER_WIDTH`, `ID_WIDTH`, or `KEEP_WIDTH`
- RAM style or implementation hint
- pipeline depth
- synchronizer depth

### Interface-profile knobs

Use these to choose how the outside world sees the family:

- native request or accept interface
- stream or `valid/ready` interface
- packetized stream profile
- command and response split profile
- status or monitoring profile

### Observability knobs

Use these for ports that surface useful status without changing the base data contract:

- occupancy outputs
- almost full or almost empty flags
- overflow or underflow diagnostics
- sticky error indicators
- performance counters

### Timing-behavior knobs

Use these only when they are documented very precisely:

- first-word fall-through
- output register enable
- combinational versus registered status
- latency mode

## How Port Reconfiguration Should Work

The preferred rule is:

- use wrapper selection when the visible port set changes
- use parameters on a stable module when only behavior or widths change

That keeps the algorithm core verifiable while still supporting Vivado-style module-family flexibility.

### Good example

An async FIFO family can have:

- `async_fifo_core` for storage, pointers, CDC, and local status math
- `async_fifo_native` for explicit write or read controls
- `async_fifo_stream` for `valid/ready`
- `async_fifo_packet` for stream plus `last` or sideband payload packing

The family remains cohesive, but each wrapper presents a clean interface contract.

### Less-good example

A single `async_fifo` with every possible port always present and a `PROFILE` parameter that tells users which subset is meaningful. That can still work internally, but it is less clean for integration, harder to lint, and more annoying for downstream tooling.

## Verification Consequences

Every public interface profile should be treated as a distinct verification target even when multiple profiles share the same core.

At minimum, each module family should document:

- supported public profiles
- legal parameter ranges per profile
- illegal parameter combinations
- which signals exist in each profile
- which shared properties should hold across every profile
- which properties are profile-specific

## Required Per-Module Artifacts

Each module family should eventually carry:

- `spec/CONFIGURATION_CONTRACT.md`
- `spec/INTERFACE_PROFILE_MATRIX.md`
- `tb/VERIFICATION_PLAN.md`

And when implementation begins:

- `tb/sim/` for simulation harnesses
- `tb/formal/` for formal harnesses and `.sby` runs
- `tb/vectors/` for reference vectors where applicable

## Verification Coverage Expectations

For configurable module families, the verification plan should cover:

1. Elaboration sweep across representative legal parameter sets
2. Directed smoke for every public interface profile
3. Randomized traffic with stalls and boundary conditions
4. Illegal-configuration checks
5. Shared semantic checks across wrappers that claim equivalent behavior
6. Formal properties on the stable core when the block is control-heavy

## Design Rule Of Thumb

If a parameter changes port meaning, it should probably create or select a wrapper.

If a parameter changes only size, latency, or thresholds while preserving port meaning, it probably belongs inside the stable module body.
