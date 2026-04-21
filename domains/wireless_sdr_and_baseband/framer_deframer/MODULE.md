# Framer or Deframer

## Overview

The framer or deframer assembles payload bits into protocol frames or extracts payloads from received frames according to the waveform's structural rules. It is the boundary between abstract payload data and protocol-defined bitstream structure.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Coding and modulation blocks need clear frame boundaries, headers, and payload layout, but leaving that structure implicit causes bit-order and length bugs across the chain. This module makes the protocol framing contract explicit.

## Typical Use Cases

- Adding headers, delimiters, and payload boundaries on a transmit path.
- Extracting payload and validating frame structure on a receive path.
- Providing reusable packetization around coded baseband data.

## Interfaces and Signal-Level Behavior

- Payload side accepts or emits raw payload bits plus length or control metadata.
- Protocol side emits or consumes framed bit streams with known boundaries.
- Control side configures frame profile, header handling, and error or status reporting.

## Parameters and Configuration Knobs

- Header length, payload length limits, bit ordering, and frame-profile count.
- CRC or auxiliary field support, idle or padding policy, and runtime profile selection.
- TX versus RX mode and status-report detail.

## Internal Architecture and Dataflow

In framing mode the block prepends or appends the necessary structural fields around payload data and emits a bitstream with explicit boundaries. In deframing mode it searches for or interprets those structures, validates them, and outputs the recovered payload. The contract should define clearly what counts as frame success or failure and where payload bits start relative to the protocol wrapper.

## Clocking, Reset, and Timing Assumptions

The module assumes the protocol profile and bit ordering match the rest of the modem chain exactly. Reset should clear any partial frame assembly or detection state.

## Latency, Throughput, and Resource Considerations

Framing logic is usually light to moderate and bounded by bit or symbol throughput rather than large arithmetic. Resource use depends mostly on buffering and header-generation logic.

## Verification Strategy

- Compare framed and deframed output against a protocol reference for several payload lengths and profiles.
- Check boundary detection, error status, and reset behavior.
- Verify padding and idle insertion or removal semantics if supported.

## Integration Notes and Dependencies

This block typically sits next to scrambling, coding, and interleaving stages, so bit ordering and frame-boundary conventions should be documented together. Integrators should also note whether CRC or integrity checks are handled here or separately.

## Edge Cases, Failure Modes, and Design Risks

- A one-bit boundary error can invalidate every downstream stage while appearing as random decoder noise.
- If RX failure semantics are vague, higher layers may not know whether to drop, retry, or partially trust a payload.
- Runtime profile switches without a clean frame boundary can corrupt adjacent frames.

## Related Modules In This Domain

- descrambler
- interleaver
- bch_codec

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Framer or Deframer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
