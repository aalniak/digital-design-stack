# Async FIFO

## Overview

`async_fifo` is a dual-clock first-in, first-out buffer used to move data safely between independently clocked regions of a digital system. Within the Core RTL Infrastructure and Glue domain, it is one of the most important composition primitives because it solves both clock-domain crossing and short-term rate mismatch at the same time.

This module should be treated as a foundational transport primitive rather than as application logic. It is typically instantiated between producers and consumers that cannot share a clock, cannot tolerate direct combinational coupling, or need elastic buffering to absorb burstiness.

This document describes the intended behavior and design expectations for an `async_fifo` module in this library, even if the final RTL implementation evolves in detail.

## Domain Context

In a reusable digital-design stack, asynchronous FIFOs sit at the boundary between otherwise well-behaved synchronous islands. They appear in SoC fabrics, DMA front ends, sensor capture pipelines, packet-processing chains, video/audio bridges, control-plane crossings, and debug infrastructure.

Unlike a simple register slice or same-clock FIFO, an asynchronous FIFO must solve three problems together:

1. Preserve ordering of payload data.
2. Cross data and status information between unrelated clock domains without metastability corrupting state.
3. Present stable backpressure and availability information so the write side and read side can make independent progress.

Because of that role, `async_fifo` is not just a storage macro wrapper. It is a CDC primitive, a buffering primitive, and a flow-control primitive all at once.

## Problem Solved

Without an asynchronous FIFO, moving multi-bit payloads between unrelated clocks is unsafe. A direct sampled bus can tear, control strobes can be missed or duplicated, and naively computed full/empty status can oscillate or become metastable.

`async_fifo` solves this by combining:

- Dual-port storage that is writable from one clock domain and readable from another.
- Independent write and read pointers that advance only in their local domains.
- Pointer synchronization logic that transfers state across the CDC boundary in a metastability-tolerant representation.
- Full and empty detection derived from synchronized remote state instead of raw unsynchronized counters.

The result is a module that lets one side push data whenever space is available and lets the other side consume data whenever entries are available, with ordering preserved and no requirement for phase or frequency relationship between clocks.

## Typical Use Cases

- Crossing sampled sensor data from an acquisition clock into a system-processing clock.
- Bridging packet or stream data from a MAC, PHY, or SERDES clock into a bus or core clock.
- Decoupling a CPU control plane from a slower or unrelated peripheral domain.
- Buffering bursts between an ingress engine and a downstream consumer that stalls intermittently.
- Moving debug or trace data into a host-accessible clock domain.
- Joining independently generated timing islands in FPGA designs where a common clock is not practical.

In this domain, `async_fifo` is usually the preferred choice when payload width is larger than a few bits and the transfer is fundamentally stream-like. Single-event transfers or infrequent status crossings are often better served by `pulse_synchronizer` or `bus_synchronizer`.

## Interfaces and Signal-Level Behavior

The exact port naming can vary, but the intended interface model is two independent local-side protocols sharing a common storage resource.

### Write-Side Interface

Typical signals:

- `wr_clk`: write-domain clock.
- `wr_rst_n` or `wr_reset`: write-domain reset.
- `wr_en` or `s_valid && s_ready`: request to enqueue one word.
- `wr_data`: payload presented by the producer.
- `full`: asserted when no additional entry can be accepted.
- `almost_full`: optional early-backpressure indicator.
- `wr_level`: optional write-domain occupancy estimate.

Write-side behavior:

- A write is accepted only on a qualified write event in the write clock domain when the FIFO is not full.
- If the producer asserts a write while `full` is asserted, the module should either ignore the write cleanly or expose an overflow flag, depending on the final interface contract. Silent corruption is never acceptable.
- `full` and any occupancy indication must be generated entirely from write-domain state plus synchronized read-domain pointer information.

### Read-Side Interface

Typical signals:

- `rd_clk`: read-domain clock.
- `rd_rst_n` or `rd_reset`: read-domain reset.
- `rd_en` or `m_valid && m_ready`: request to dequeue one word.
- `rd_data`: payload returned to the consumer.
- `empty`: asserted when no valid entry is available.
- `almost_empty`: optional low-watermark indicator.
- `rd_level`: optional read-domain occupancy estimate.

Read-side behavior:

- A read is accepted only on a qualified read event in the read clock domain when the FIFO is not empty.
- If the consumer attempts to read while `empty` is asserted, the module should either hold output stable and ignore the read or expose an underflow flag, depending on the final contract.
- `empty` and any occupancy estimate must be generated from read-domain state plus synchronized write-domain pointer information.

### Payload Semantics

- Data ordering must be strictly first-in, first-out.
- No duplication, omission, or reordering is allowed under any legal sequence of writes and reads.
- Payload bits are opaque to the FIFO; interpretation belongs to surrounding logic.
- Sideband information such as `last`, `keep`, packet type, or error bits can be carried by widening the stored word rather than changing the FIFO algorithm.

## Parameters and Configuration Knobs

The intended configuration surface for `async_fifo` should include most or all of the following parameters:

- `DATA_WIDTH`: payload width in bits.
- `DEPTH`: number of stored entries. Power-of-two depth is strongly preferred because it simplifies pointer wrap and Gray-code full detection.
- `ADDR_WIDTH`: derived from depth, typically `ceil(log2(DEPTH))`.
- `RAM_STYLE`: optional implementation hint such as registers, LUT RAM, block RAM, or inferred memory.
- `SYNC_STAGES`: number of synchronizer stages used when transferring Gray-coded pointers across domains. Two stages is the common default; three may be justified for aggressive MTBF targets.
- `ALMOST_FULL_THRESHOLD`: optional threshold for early write throttling.
- `ALMOST_EMPTY_THRESHOLD`: optional threshold for early read-side refill signaling.
- `SHOW_AHEAD` or `FWFT`: optional first-word fall-through behavior if the library chooses to support both registered-output and look-ahead variants.
- `OUTPUT_REG`: optional read-data output register enable for timing closure.
- `OVERFLOW_FLAG_EN` and `UNDERFLOW_FLAG_EN`: optional diagnostic signaling.

Recommended defaults:

- Favor power-of-two depth.
- Default to two-stage pointer synchronizers.
- Make optional status signals synthesizable only when enabled so the minimal configuration stays compact.

## Internal Architecture and Dataflow

The canonical internal structure is a dual-clock circular buffer with separate write and read pointer machines.

### Storage Array

The FIFO stores payload words in a memory indexed by the lower address bits of the local pointer. The storage should support one write on `wr_clk` and one read on `rd_clk` without requiring the two clocks to be related.

Implementation options include:

- Register-based arrays for very shallow FIFOs.
- LUT RAM or distributed RAM for moderate depth in FPGA fabrics.
- Block RAM or embedded memory macros for larger payloads or deeper buffering.

### Pointer Scheme

Each side usually tracks:

- A binary pointer for memory addressing and local arithmetic.
- A Gray-coded version of that pointer for CDC export.

The extra wrap bit is important. Full and empty detection generally depend on distinguishing "same address, different wrap state" from "same address, same wrap state."

### CDC Strategy

The standard approach is:

1. Convert the local binary pointer to Gray code.
2. Synchronize the Gray-coded pointer into the remote clock domain using a small chain of flip-flops.
3. Perform full or empty comparisons against the synchronized pointer in the local domain.

Gray coding is used because only one bit changes per increment, which minimizes ambiguity when the remote domain samples a transitioning pointer. The synchronized Gray pointer may still be delayed, but it should not represent arbitrary multi-bit corruption.

### Full Detection

Full detection is performed in the write domain by comparing the next write pointer against the synchronized read pointer with wrap interpretation. In common power-of-two FIFO designs, the FIFO is full when the next Gray-coded write pointer equals the synchronized read pointer with the upper bits inverted according to the wrap rule.

### Empty Detection

Empty detection is performed in the read domain when the next read position catches up to the synchronized write pointer. For a standard design, empty means the current or next read Gray pointer equals the synchronized Gray write pointer, depending on whether the implementation uses combinational next-state prediction.

### Occupancy and Watermarks

Accurate global occupancy is inherently approximate across asynchronous domains because each side observes a delayed copy of the other pointer. Any level indication must be documented as local-domain-consistent, not globally instantaneous. That is acceptable for watermarks, throttling, and software observability, but it matters if exact counts are assumed by surrounding logic.

## Clocking, Reset, CDC, and Timing Assumptions

`async_fifo` exists specifically because `wr_clk` and `rd_clk` are asynchronous or at least unrelated enough that direct timing assumptions are unsafe.

Key assumptions:

- No fixed frequency ratio or phase relationship is required between `wr_clk` and `rd_clk`.
- Pointer synchronizer paths must be treated as CDC paths in timing and signoff flows.
- The memory primitive must legally support independent read and write clocks.

Reset strategy should be chosen deliberately. The most robust convention for this domain is:

- Asynchronous assertion if required by platform startup behavior.
- Synchronous release within each local domain.
- Local pointer and status initialization in each domain to the empty state.

Important reset notes:

- If one side exits reset much earlier than the other, the design should still converge safely to an empty FIFO once pointer synchronization settles.
- Reset deassertion ordering must not create a false full or false empty condition that persists indefinitely.
- Any status flags exported to software or monitoring logic should document transient behavior during startup and immediately after reset release.

CDC constraints should explicitly identify:

- Gray-pointer synchronizer chains as asynchronous crossings.
- False-path or asynchronous-clock-group relationships between write and read domains where appropriate.
- Memory macro timing exceptions only if supported by the target technology flow.

## Latency, Throughput, and Resource Considerations

### Latency

Write-to-read latency depends on:

- Whether the read path is registered.
- Whether the FIFO supports first-word fall-through behavior.
- The read-domain observation delay of the synchronized write pointer.

The stored data itself is available in memory immediately after a successful write from the write-domain perspective, but the read domain typically sees availability only after pointer synchronization delay plus local control latency.

### Throughput

Under steady-state conditions, an asynchronous FIFO should support:

- Up to one accepted write per `wr_clk` cycle when not full.
- Up to one accepted read per `rd_clk` cycle when not empty.

The practical sustained throughput is bounded by the slower average side over long windows, but burst absorption depends on depth.

### Resource Tradeoffs

- Shallow FIFOs are cheaper in registers and have simple timing, but they absorb less jitter and burst mismatch.
- Deep FIFOs improve elasticity and MTBF margins for bursty systems but may increase BRAM use, pointer width, and status-logic cost.
- Optional occupancy reporting and watermark logic add arithmetic and comparison logic in each local domain.
- Registered read outputs help timing closure but may add latency.

## Verification Strategy

An `async_fifo` deserves stronger verification than many other infrastructure blocks because CDC bugs are subtle and often escape simple directed tests.

Recommended verification layers:

### Directed Tests

- Reset to empty and verify both sides observe the empty condition.
- Single write then single read across unrelated clock frequencies.
- Fill to full and verify no overflow corruption.
- Drain to empty and verify no underflow corruption.
- Wrap pointers multiple times with interleaved writes and reads.

### Randomized Simulation

- Sweep independent write and read clocks with varying periods and phase drift.
- Randomize write bursts, read bursts, stalls, and simultaneous activity.
- Check strict ordering against a software queue model.
- Exercise transitions around full, almost full, empty, and almost empty boundaries.

### Assertion-Based Checks

- Never read uninitialized or invalid entry data after a legal transfer sequence.
- Never report full and empty simultaneously except possibly during reset transients if the implementation documents that behavior explicitly.
- Write count minus read count should remain within legal bounds.
- A successful write must eventually become readable unless reset intervenes.

### Formal Verification

This module is a strong candidate for formal proof, especially for:

- No overflow beyond configured depth.
- No underflow below zero occupancy.
- Preservation of FIFO ordering.
- Correct full and empty flag transitions.
- Correctness of Gray-pointer one-hot transition property.

## Integration Notes and Dependencies

`async_fifo` is often instantiated below higher-level interfaces rather than exposed directly to software. Integration choices matter:

- For `valid/ready` streams, map write acceptance to `s_valid && s_ready` and read acceptance to `m_valid && m_ready`.
- For packet streams, include packet metadata such as `last` or error bits in the stored payload width.
- For bus crossings, ensure request and response ordering rules are respected before blindly placing FIFOs in each direction.
- For sensor pipelines, choose depth based on worst-case burst and downstream service latency, not average rate alone.

Dependencies and companion blocks in this domain may include:

- `reset_synchronizer` for safe local reset release.
- `skid_buffer` or `register_slice` around the FIFO to ease timing on stream interfaces.
- `width_converter` before or after the FIFO if crossing domains also changes word packing.
- `packetizer` or `depacketizer` when the FIFO is part of a framed transport path.

Physical implementation notes:

- Keep synchronizer flops physically constrained according to CDC best practice.
- Prefer memory styles with well-defined dual-clock semantics on the target FPGA or ASIC technology.
- Do not let synthesis "optimize" synchronizer chains into generic logic structures.

## Edge Cases, Failure Modes, and Design Risks

- Non-power-of-two depth complicates pointer arithmetic and full detection; if supported, it should be justified and heavily verified.
- Reset asymmetry between domains can create temporary flag disagreement; this must settle safely without corrupting state.
- Occupancy outputs can be misused as exact real-time counts even though they reflect synchronized remote state with delay.
- Poorly constrained synchronizer chains can cause false timing failures or, worse, accidental optimization that reduces MTBF.
- Choosing too shallow a depth can make the FIFO correct but system-level performance unstable under burst load.
- First-word fall-through variants are convenient, but they complicate empty semantics and read-side timing closure.
- Vendor memory inference differences can subtly change read-during-write behavior, so the expected behavior must be documented and checked.

Common failure signatures in practice include:

- `full` asserting one cycle too early or too late due to incorrect next-pointer comparison.
- `empty` deasserting late because synchronized pointers are interpreted incorrectly.
- Data duplication or skipping around wrap boundaries.
- Broken behavior only at certain clock ratios because the CDC logic was modeled incorrectly.

## Related Modules In This Domain

- `pulse_synchronizer`: better for isolated event crossings than for queued payload data.
- `bus_synchronizer`: suitable for carefully controlled low-bandwidth status transfer, not for stream buffering.
- `stream_fifo`: use when both sides share a clock and only elasticity is needed.
- `register_slice`: use for same-domain timing relief with minimal storage.
- `skid_buffer`: use for short backpressure absorption without a deep queue.
- `width_converter`: pair with `async_fifo` when CDC and data repacking happen at the same boundary.

## Documentation Status

This `MODULE.md` should be treated as the deep, domain-specific reference for the `async_fifo` folder in this library taxonomy. As RTL is added later, the implementation should either conform to this contract or this document should be revised to reflect the implemented behavior precisely.
