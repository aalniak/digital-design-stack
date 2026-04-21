# Circular Buffer

## Overview

circular_buffer stores a moving window of data in a ring structure so producers and consumers can operate on a bounded history without shifting the stored contents. It is a reusable primitive for streaming history, delay lines, and overwrite-on-wrap storage.

## Domain Context

In the Buffering, Memory, and Data Movement domain, modules are judged by how clearly they define storage ownership, latency, burst semantics, backpressure, coherency boundaries, and error behavior. These blocks frequently sit between fast producers, slower memories, and shared interconnect.

## Problem Solved

Streaming systems often need a fixed-size rolling history. Shifting memory contents every cycle is wasteful, and ad hoc ring logic often mishandles wrap, full-versus-empty distinction, and overwrite policy. circular_buffer solves those issues directly.

## Typical Use Cases

- Maintain a rolling sample history for DSP or control.
- Implement queue-like storage where old entries are overwritten after wrap.
- Back a software-visible ring of records or trace entries.

## Interfaces and Signal-Level Behavior

- Inputs typically include write data, write enable, optional read address or read pop control, and reset.
- Outputs include read data and often occupancy, full, empty, or wrapped status.
- Some variants expose random-access taps relative to the current head or tail.

## Parameters and Configuration Knobs

- DATA_WIDTH sets stored element width.
- DEPTH sets ring capacity.
- OVERWRITE_MODE defines whether new writes overwrite the oldest entry or stall when full.
- TAP_ACCESS_EN enables indexed reads into the ring history.
- COUNT_EN adds occupancy reporting.

## Internal Architecture and Dataflow

The core design uses head and tail pointers or a head pointer plus occupancy count depending on whether reads are sequential, random, or both. The central contract question is what happens when a write arrives to a full structure and whether that policy preserves or discards the oldest data.

## Clocking, Reset, and Timing Assumptions

A circular buffer can look like a FIFO but does not always behave like one; callers need to know whether it is queue-ordered, overwrite-on-wrap, or history-addressable. Reset should establish pointer state and define whether contents are considered valid.

## Latency, Throughput, and Resource Considerations

Ring storage is efficient because it avoids memory shifting. Throughput is usually one local write and one local read per cycle if the underlying storage supports it. Cost is dominated by storage plus pointer and occupancy logic.

## Verification Strategy

- Exercise wraparound repeatedly under read and write activity.
- Check overwrite-on-full versus stall-on-full policy exactly.
- Verify indexed history taps if supported.
- Stress transitions between empty, partially full, and wrapped states.

## Integration Notes and Dependencies

circular_buffer commonly appears in delay lines, rolling telemetry, and history-based algorithms. It pairs naturally with line_buffer, ping_pong_buffer, and frame or sample capture logic depending on access style.

## Edge Cases, Failure Modes, and Design Risks

- Full-versus-empty distinction is a classic ring-buffer bug.
- Overwrite semantics can silently discard data if system-level ownership is unclear.
- Random-access taps relative to moving pointers are easy to misdocument.

## Related Modules In This Domain

- line_buffer
- ping_pong_buffer
- frame_buffer
- stream_fifo

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Circular Buffer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
