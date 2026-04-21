# Verification Strategy For Reconfigurable Modules

## Goal

This library is being shaped as a catalog of highly reconfigurable digital IP. A module should not be treated as verified only because one default parameterization works. Verification needs to demonstrate that the module contract holds across its supported interface profiles, width settings, optional features, buffering modes, and timing assumptions.

## Design Principle

A configurable module should expose a documented contract first and an implementation second. The verification plan should prove that each legal configuration behaves consistently with that contract, especially when the visible port set or protocol behavior changes in ways similar to Vivado-style interface options.

## Verification Layers

1. Elaboration and configuration sweep
   - Compile the module across a representative matrix of legal parameter sets.
   - Cover narrow and wide datapaths, minimum and maximum FIFO depths, enabled and disabled optional sidebands, single-lane and multi-lane modes, and reset or clocking variants when those are legal.
   - Fail fast on illegal combinations by checking that the RTL either rejects them clearly or documents them as unsupported.

2. Static structural sanity
   - Run synthesis parsing and basic optimization to catch incomplete generates, width mismatches, unconnected optional logic, and unintended latches.
   - Use this stage as a lightweight gate before deeper simulation or formal runs.

3. Directed simulation smoke tests
   - Prove each module can reset, accept traffic or stimuli, produce observable output, and survive a basic backpressure or idle scenario.
   - Keep one fast smoke path for every module so the library can always answer the question, "does this configuration even run?"

4. Protocol and corner-case simulation
   - Add randomized stalls, burst boundaries, packet boundaries, repeated resets, empty or full transitions, signed overflow cases, and parameter extremes.
   - For configurable interfaces, test every supported profile rather than assuming one superset port map is enough.

5. Formal verification where it pays off
   - Use formal aggressively for control-heavy modules such as FIFOs, arbiters, CDC shims, counters, protocol bridges, and state machines.
   - Target invariants like ordering, no data duplication, no data loss, eventual progress, handshake safety, reset convergence, and one-hot or mutually exclusive grants.

6. Domain-specific reference checking
   - For arithmetic, DSP, image, codec, and ML blocks, compare RTL outputs against a golden model or trusted vector set.
   - Treat numerical tolerances explicitly. Fixed-point rounding, saturation, clipping, and latency alignment should all be part of the expected contract.

## What Highly Reconfigurable Modules Must Document

Each module should eventually describe the following inside `spec/`:

- Supported interface profiles
- Parameter list, legal ranges, and illegal combinations
- Which parameters alter internal behavior only and which parameters alter visible ports
- Reset semantics
- Clock-domain assumptions
- Ordering rules, packet rules, and backpressure rules
- Latency model, including whether latency is fixed or parameter-dependent
- Error signaling or assertion behavior for unsupported settings

## Expected Folder Roles

- `rtl/`: synthesizable source files and interface wrappers
- `tb/`: simulation testbenches, formal harnesses, reference vectors, and regression entry points
- `spec/`: configuration contract, interface profiles, timing assumptions, and verification intent

## Suggested Verification Maturity Levels

- `bronze`: elaboration sweep plus one directed smoke test
- `silver`: randomized simulation across multiple parameter sets plus basic synthesis sanity
- `gold`: formal coverage for control properties or golden-model checking for numerical blocks
- `production`: regression automation, interface profile coverage, and documented pass criteria

## Initial Tooling Baseline

The current repository verification baseline is centered on OSS CAD Suite:

- `iverilog` for quick compile and smoke simulation
- `vvp` for simulation execution
- `yosys` for structural sanity and synthesis-oriented checks
- `sby` plus `z3` for formal smoke and control-property proofs
- `gtkwave` for waveform inspection when a failure needs interactive debugging

## Windows-Specific Reality

On this machine the OSS CAD Suite tools are installed, but not exposed on the default shell `PATH`. Verification scripts should activate the suite environment explicitly rather than assuming a globally configured shell. The repository status report captures the exact verified state in `verification/ENVIRONMENT_STATUS.md`.

## Near-Term Implementation Pattern

As we begin populating the module folders, the intended pattern is:

1. Add `rtl/`, `tb/`, and `spec/` to every module
2. Capture the interface and configuration contract in `spec/`
3. Add a smoke test in `tb/`
4. Add a representative parameter sweep
5. Promote control-oriented modules to formal proofs
6. Promote numeric modules to vector-based checking

This keeps the stack scalable while still respecting that configurable IP is only reusable when its supported configuration space is actually exercised.
