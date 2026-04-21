# Async FIFO Verification Plan

## Verification Scope

- Family name: `async_fifo`
- Stable core under test: `async_fifo_core`
- Public wrappers in scope:
  - `async_fifo_native`
  - `async_fifo_stream`
  - `async_fifo_packet`
- Toolchain baseline:
  - `iverilog` and `vvp` for fast smoke simulation
  - `yosys` for synthesis sanity
  - `sby` plus `z3` for formal proof on the core

## Verification Intent

The verification goal is not just to show that one FIFO instance works. The goal is to show that the family remains correct across:

- multiple widths
- multiple depths
- multiple synchronizer depths
- multiple public interface profiles
- optional observability features
- meaningful clock ratio and phase combinations

The highest-risk areas are CDC correctness, full or empty boundary behavior, reset convergence, and wrapper semantics around backpressure.

## Configuration Sweep Matrix

| Case id | Profile | Key parameters | Why this case matters | Expected flow |
| --- | --- | --- | --- | --- |
| `A1` | `native` | `DATA_WIDTH=8`, `DEPTH=4`, `SYNC_STAGES=2` | Smallest practical FIFO for quick smoke and wrap behavior | smoke simulation, formal |
| `A2` | `native` | `DATA_WIDTH=32`, `DEPTH=16`, `SYNC_STAGES=2` | Baseline practical configuration | smoke simulation, randomized simulation, formal |
| `A3` | `native` | `DATA_WIDTH=64`, `DEPTH=64`, `SYNC_STAGES=3` | Wider and deeper FIFO with stronger MTBF target | compile, randomized simulation |
| `B1` | `stream` | `DATA_WIDTH=32`, `DEPTH=16`, `FWFT=0` | Basic stream wrapper semantics | smoke simulation |
| `B2` | `stream` | `DATA_WIDTH=32`, `DEPTH=16`, `EXPOSE_LEVELS=1`, `EXPOSE_WATERMARKS=1` | Observability ports enabled | smoke simulation, randomized simulation |
| `C1` | `packet` | `DATA_WIDTH=32`, `DEPTH=16`, `KEEP_ENABLE=0`, `USER_ENABLE=0` | Minimal packet mode with `last` only | smoke simulation |
| `C2` | `packet` | `DATA_WIDTH=64`, `DEPTH=32`, `KEEP_ENABLE=1`, `KEEP_WIDTH=8`, `USER_ENABLE=1`, `USER_WIDTH=4` | Richest sideband profile | compile, randomized simulation |
| `X1` | invalid | `DEPTH=12` | Verifies clear rejection of unsupported depth | compile failure check |
| `X2` | invalid | `PROFILE=stream`, `KEEP_ENABLE=1` | Verifies sideband misuse is rejected | compile failure check |

## Directed Simulation

The directed suite should cover:

- reset to empty in both domains
- single write then single read across unrelated clocks
- fill to full and verify write-side rejection behavior
- drain to empty and verify read-side rejection behavior
- pointer wrap with multiple laps through storage
- simultaneous read and write activity under non-harmonic clocks
- staggered reset release between domains

Per wrapper additions:

- `native`: direct push or pop semantics and local status signals
- `stream`: source and sink stalls, transfer hold behavior, and handshake persistence
- `packet`: packet boundary alignment and sideband preservation

## Randomized Simulation

The randomized suite should vary:

- write clock period
- read clock period
- phase drift between domains
- burst length
- idle gaps
- stall insertion
- reset timing
- packet sideband patterns when packet mode is enabled

The scoreboard should use a software queue model containing the full packed entry:

- payload
- packet sidebands if enabled
- expected transfer order

## Assertions And Scoreboarding

Simulation should eventually include:

- occupancy stays between zero and `DEPTH`
- no successful read when the reference queue is empty
- no successful write when the reference queue is full unless overflow behavior is explicitly diagnostic-only
- data and sideband ordering match the scoreboard exactly
- wrapper handshakes map one-for-one to accepted enqueue and dequeue events

## Formal Verification

Formal should focus first on `async_fifo_core` and then add wrapper-local properties where useful.

Core properties:

- binary pointers advance only on legal local transfers
- Gray pointers change one bit at a time
- full and empty conditions are mutually consistent with pointer relationships
- occupancy never exceeds depth
- occupancy never becomes negative
- accepted writes eventually become observable reads unless reset intervenes
- no reordering occurs

Wrapper-local properties:

- `native`: handshake acceptance reflects core push or pop exactly
- `stream`: transfers only occur on `valid && ready`
- `packet`: sidebands remain aligned with payload across wrapper packing

## Illegal-Configuration Checks

The family should reject or flag:

- non-power-of-two `DEPTH`
- `SYNC_STAGES < 2`
- packet-only sidebands enabled outside `packet` profile
- incompatible latency-mode combinations
- invalid threshold ranges

These checks can be implemented with elaboration-time assertions or parameter guards and must be exercised intentionally.

## Coverage Goals

The family should earn coverage across:

- all public interface profiles
- at least three meaningful data widths
- shallow, medium, and deep FIFOs
- two-stage and three-stage synchronizers
- observability features both disabled and enabled
- packet sidebands both absent and present
- reset skew scenarios

## Pass Criteria

- `bronze`: core compiles, baseline smoke simulation passes, synthesis sanity passes
- `silver`: representative parameter sweep plus randomized simulation on each public wrapper
- `gold`: formal proof of core invariants plus wrapper handshake assertions
- `production`: regression automation, documented illegal-configuration checks, and waveform-friendly debug support

## Planned Testbench Layout

- `tb/sim/`
  - directed smoke tests
  - randomized queue-based testbench
  - wrapper-specific harnesses
- `tb/formal/`
  - `async_fifo_core` proof harness
  - wrapper-local property harnesses if needed
- `tb/vectors/`
  - reserved for explicit regression vectors or packet-sideband reference traces if simulation grows that way

## Implementation Order

1. Bring up `async_fifo_core` in a native profile with a simple smoke test
2. Add synthesis sanity and formal proof on the core
3. Add the `native` wrapper scoreboard test
4. Add the `stream` wrapper and its stall tests
5. Add the `packet` wrapper and sideband alignment tests
6. Expand the parameter sweep into regression automation
