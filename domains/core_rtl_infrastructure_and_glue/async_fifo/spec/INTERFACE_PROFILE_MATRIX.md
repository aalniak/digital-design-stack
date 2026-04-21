# Async FIFO Interface Profile Matrix

## Intent

This matrix captures how the `async_fifo` family is allowed to look at the top level. It exists so interface flexibility stays explicit and verifiable.

## Profile Summary

| Profile | Wrapper | Source-side clock | Sink-side clock | Base handshake style |
| --- | --- | --- | --- | --- |
| `native` | `async_fifo_native` | `wr_clk` | `rd_clk` | Explicit local write/read request-accept semantics |
| `stream` | `async_fifo_stream` | `s_clk` | `m_clk` | `valid/ready` |
| `packet` | `async_fifo_packet` | `s_clk` | `m_clk` | `valid/ready` plus packet sidebands |

## Native Profile

### Required port groups

- write clock and reset
- read clock and reset
- write payload and write accept request
- read payload and read accept request
- full and empty indication

### Recommended public signals

| Direction | Signals |
| --- | --- |
| write side input | `wr_clk`, `wr_rst_n`, `wr_valid`, `wr_data` |
| write side output | `wr_ready`, `full` |
| read side input | `rd_clk`, `rd_rst_n`, `rd_ready` |
| read side output | `rd_valid`, `rd_data`, `empty` |

### Optional signals

- `almost_full`
- `almost_empty`
- `wr_level`
- `rd_level`
- `overflow`
- `underflow`

## Stream Profile

### Required port groups

- source clock and reset
- sink clock and reset
- stream source payload and handshake
- stream sink payload and handshake

### Recommended public signals

| Direction | Signals |
| --- | --- |
| source side input | `s_clk`, `s_rst_n`, `s_valid`, `s_data` |
| source side output | `s_ready` |
| sink side input | `m_clk`, `m_rst_n`, `m_ready` |
| sink side output | `m_valid`, `m_data` |

### Optional signals

- `s_level`
- `m_level`
- `s_almost_full`
- `m_almost_empty`
- sticky error or event flags

## Packet Profile

### Required port groups

- everything in the stream profile
- packet sideband transport

### Recommended public signals

| Direction | Signals |
| --- | --- |
| source side input | `s_clk`, `s_rst_n`, `s_valid`, `s_data`, `s_last` |
| source side output | `s_ready` |
| sink side input | `m_clk`, `m_rst_n`, `m_ready` |
| sink side output | `m_valid`, `m_data`, `m_last` |

### Optional packet sidebands

- `s_keep` and `m_keep`
- `s_user` and `m_user`
- `s_err` and `m_err`

## Shared Verification Obligations

Every profile must preserve:

- ordering
- reset convergence to empty
- no overflow corruption
- no underflow corruption
- correct backpressure behavior

## Profile-Specific Verification Obligations

### Native

- write-side and read-side handshakes map correctly to internal push and pop events
- `full` and `empty` are locally stable and do not glitch meaningfully across clock boundaries

### Stream

- `s_valid/s_ready` acceptance semantics are preserved
- `m_valid/m_ready` consumption semantics are preserved
- wrapper does not create duplicate transfers when stalls are inserted

### Packet

- sidebands remain aligned with payload data
- packet boundary markers such as `last` preserve FIFO ordering
- optional sideband enable parameters do not silently change packet semantics

## Wrapper Equivalence Expectation

When `async_fifo_native`, `async_fifo_stream`, and `async_fifo_packet` are configured to carry the same effective payload information, they should be semantically equivalent with respect to:

- ordering
- drop or duplication behavior
- reset convergence
- watermark threshold behavior

The wrappers are allowed to differ in handshake vocabulary, not in FIFO semantics.
