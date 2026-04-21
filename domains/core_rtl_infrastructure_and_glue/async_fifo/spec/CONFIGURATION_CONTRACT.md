# Async FIFO Configuration Contract

## Module Family

- Family name: `async_fifo`
- Domain: Core RTL Infrastructure and Glue
- Stable core name: `async_fifo_core`
- Planned public wrappers:
  - `async_fifo_native`
  - `async_fifo_stream`
  - `async_fifo_packet`

## Purpose

The `async_fifo` family moves ordered payload data between unrelated clock domains while providing elastic buffering and locally safe flow control. The family is expected to support multiple public-facing port styles because different projects want different integration surfaces:

- explicit native enqueue and dequeue controls
- stream-style `valid/ready`
- packet-carrying stream variants with sideband transport

The key design goal is to make the family configurable without making the core ambiguous.

## Family Architecture

The recommended implementation split for this family is:

1. `async_fifo_core`
   - Owns storage, binary and Gray pointers, CDC synchronizers, full or empty detection, watermarks, and optional diagnostic flags.
   - Uses a stable internal contract so the FIFO algorithm can be verified once and reused everywhere.

2. `async_fifo_native`
   - Presents explicit write-domain and read-domain controls such as `wr_valid`, `wr_ready`, `rd_valid`, and `rd_ready`.
   - Best fit for low-level glue logic, DMA plumbing, and custom transport fabrics.

3. `async_fifo_stream`
   - Adapts the core to source-side and sink-side `valid/ready` semantics.
   - Best fit for generic streaming pipelines.

4. `async_fifo_packet`
   - Extends the stream wrapper by packing sidebands like `last`, `keep`, `user`, or packet error flags into the stored word or by carrying them in a structured sideband channel.
   - Best fit for packet or frame pipelines.

The module folder represents the family as a whole. The public wrappers should stay thin; the stable core should carry the behavioral complexity.

## Supported Public Profiles

| Profile | Intended use | Public port style | Notes |
| --- | --- | --- | --- |
| `native` | Generic CDC buffering between custom producer and consumer logic | Explicit local write and read controls | Preferred baseline profile for algorithm bring-up |
| `stream` | Stream pipelines with backpressure | `s_valid/s_ready` and `m_valid/m_ready` semantics split across source and sink clocks | Keeps stream semantics clean without exposing low-level pointer ideas |
| `packet` | Packet or frame pipelines | Stream semantics plus packet sidebands | Sidebands should be packed consistently and verified with payload ordering |

## Shared Semantic Contract

The following rules must hold across every public profile:

- Data ordering is strictly first-in, first-out.
- No legal transfer sequence may duplicate, drop, or reorder payload entries.
- Full and empty behavior is derived from synchronized remote pointers, never from raw unsynchronized state.
- Reset converges to an empty FIFO in both domains even if reset release is staggered.
- Backpressure and availability signals are generated in the local domain only.
- Optional occupancy or watermark outputs are local-domain-consistent estimates, not globally instantaneous truths.
- Illegal writes when full and illegal reads when empty must never corrupt stored data.

## Parameters

| Parameter | Type | Legal range | Default | Affects ports? | Meaning |
| --- | --- | --- | --- | --- | --- |
| `DATA_WIDTH` | integer | `>= 1` | `32` | no | Payload width for the base data word |
| `DEPTH` | integer | power-of-two, `>= 4` | `16` | no | Number of storable entries |
| `SYNC_STAGES` | integer | `2` to `4` | `2` | no | Pointer synchronizer depth in each direction |
| `RAM_STYLE` | string or enum | implementation-defined | `auto` | no | Storage inference hint |
| `FWFT` | bit | `0` or `1` | `0` | no | First-word fall-through behavior |
| `OUTPUT_REG` | bit | `0` or `1` | `1` | no | Read-data output register insertion |
| `ALMOST_FULL_THRESHOLD` | integer | `1` to `DEPTH-1` | `DEPTH-2` | no | Early backpressure threshold |
| `ALMOST_EMPTY_THRESHOLD` | integer | `0` to `DEPTH-1` | `1` | no | Early refill threshold |
| `EXPOSE_LEVELS` | bit | `0` or `1` | `0` | wrapper-dependent | Enables local occupancy outputs |
| `EXPOSE_WATERMARKS` | bit | `0` or `1` | `0` | wrapper-dependent | Enables almost-full and almost-empty outputs |
| `EXPOSE_ERROR_FLAGS` | bit | `0` or `1` | `0` | wrapper-dependent | Enables overflow and underflow diagnostics |
| `PROFILE` | enum | `native`, `stream`, `packet` | `native` | yes | Selects the public wrapper profile |
| `KEEP_ENABLE` | bit | `0` or `1` | `0` | packet only | Enables byte-lane keep sideband |
| `KEEP_WIDTH` | integer | `>= 1` | derived | packet only | Width of the keep sideband when enabled |
| `USER_ENABLE` | bit | `0` or `1` | `0` | packet only | Enables packet user sideband |
| `USER_WIDTH` | integer | `>= 1` | `1` | packet only | Width of packet user sideband |

### Parameter Categories

Structural parameters:

- `DATA_WIDTH`
- `DEPTH`
- `SYNC_STAGES`
- `RAM_STYLE`

Timing and latency parameters:

- `FWFT`
- `OUTPUT_REG`

Observability parameters:

- `EXPOSE_LEVELS`
- `EXPOSE_WATERMARKS`
- `EXPOSE_ERROR_FLAGS`

Interface-profile parameters:

- `PROFILE`
- `KEEP_ENABLE`
- `KEEP_WIDTH`
- `USER_ENABLE`
- `USER_WIDTH`

## Port Visibility Policy

The family should not rely on one giant public module whose ports are only conditionally meaningful. The preferred policy is:

- choose the visible port set with wrapper selection
- use parameters to vary widths, depths, timing modes, and observability within that wrapper

That means:

- `async_fifo_native` exposes native local write and read controls
- `async_fifo_stream` exposes stream-side handshakes
- `async_fifo_packet` exposes stream-side handshakes plus packet sidebands

If the project later chooses to use SystemVerilog interfaces, those should wrap the same semantic contract rather than replacing it with a different one.

## Illegal Or Unsupported Combinations

The family should reject or clearly document at least the following:

- non-power-of-two `DEPTH` if the implementation chooses the standard Gray-pointer scheme
- `SYNC_STAGES < 2`
- `FWFT = 1` together with `OUTPUT_REG = 1` if the chosen architecture cannot honor both semantics cleanly
- `KEEP_ENABLE = 1` when `PROFILE != packet`
- `USER_ENABLE = 1` when `PROFILE != packet`
- `KEEP_WIDTH` inconsistent with payload byte lanes when packet keep semantics are byte-oriented
- thresholds outside the valid occupancy range

## Reset And Clocking Assumptions

- `wr_clk` and `rd_clk` are asynchronous or unrelated enough that direct timing assumptions are unsafe.
- Reset assertion may be asynchronous if platform startup requires it, but release should be synchronized in each local domain.
- Pointer synchronizer chains must be treated as CDC structures in timing and signoff flows.
- The family must converge safely to empty even when one domain exits reset before the other.

## Verification Impact

The configuration space should be verified in layers:

- full sweep for representative values of `DATA_WIDTH`, `DEPTH`, and `SYNC_STAGES`
- spot checks for `RAM_STYLE`
- explicit smoke and stress tests for every public profile
- dedicated tests for every enabled observability group
- formal focus on `async_fifo_core`, not just the wrappers

`PROFILE` is a first-class verification axis, not a documentation detail.

## Planned RTL Family Layout

When implementation starts, the expected files under `rtl/` are:

- `async_fifo_core.sv`
- `async_fifo_native.sv`
- `async_fifo_stream.sv`
- `async_fifo_packet.sv`
- `async_fifo_pkg.sv` if shared type or parameter declarations become useful

## Integration Notes

- Packet sidebands should be packed consistently and documented clearly so ordering checks can use a single scoreboard item format.
- Occupancy outputs should be documented as local-domain-consistent estimates.
- Wrapper selection should be explicit in integration code so downstream users do not need to guess which ports are meaningful for a given configuration.
