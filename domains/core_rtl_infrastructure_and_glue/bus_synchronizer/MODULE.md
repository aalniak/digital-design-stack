# Bus Synchronizer

## Overview

`bus_synchronizer` is a clock-domain crossing helper for transferring a multi-bit value from one clock domain to another when the value changes slowly enough, or is held stable long enough, for safe capture under a defined synchronization method. Within the Core RTL Infrastructure and Glue domain, it fills the gap between a one-bit event synchronizer and a full asynchronous FIFO.

This module should not be treated as a generic "sample any bus anywhere" primitive. A multi-bit bus cannot be made safe merely by placing independent synchronizers on each bit. Instead, `bus_synchronizer` exists to impose a disciplined crossing contract so that a destination domain receives a coherent word rather than a torn or partially updated value.

The intended use of this module is low-bandwidth control, status, configuration, mode, and measurement transfer. It is not the right primitive for sustained payload streams or bursty data transport.

## Domain Context

Reusable digital systems need a family of CDC primitives, not a single universal one. In that family:

- `pulse_synchronizer` handles sparse events.
- `bus_synchronizer` handles low-rate multi-bit values.
- `async_fifo` handles queued payload streams.

That middle category is common. Designers often need to move values such as:

- Error codes.
- FSM states exported for debug.
- Thresholds or coefficients loaded by software.
- Timestamp snapshots.
- Slow counters or measurement results.
- Mode selects and control words.

These values are wider than one bit, but they do not justify the complexity or buffering semantics of a FIFO. `bus_synchronizer` gives the library a reusable answer for that class of crossings.

## Problem Solved

The core problem is that a multi-bit bus crossing between unrelated clocks can be observed incoherently if bits are sampled during different transitions. Even if every bit is individually synchronized, the destination may see a word that never actually existed in the source domain.

`bus_synchronizer` solves this by enforcing one of a small set of safe transfer models:

1. A level-stable transfer where the source guarantees the bus remains unchanged for long enough to be sampled coherently.
2. A handshake-based transfer where the source presents data, requests transfer, and holds the data stable until an acknowledgment or completion condition is met.
3. A toggle-based or snapshot-based transfer where a control transition indicates that a new stable word is available.

The exact microarchitecture may vary, but the contract is always the same: the destination must capture a complete, self-consistent bus value under clearly documented stability assumptions.

## Typical Use Cases

- Crossing software-programmed control registers from a CPU bus clock into a peripheral clock.
- Exporting a hardware status word from a peripheral clock into a system-monitor clock.
- Transferring sampled counters, period measurements, or alarm vectors into a supervisory domain.
- Sending a mode or configuration word into a DSP, video, or sensor-processing clock domain at frame or block boundaries.
- Latching a debug snapshot into a host-visible domain.

Typical situations where `bus_synchronizer` is the wrong choice:

- High-throughput sample streams.
- Packet payload transport.
- Frequent back-to-back transfers with no stable hold interval.
- Traffic that needs per-word queuing, lossless burst absorption, or precise throughput guarantees.

In those cases, `async_fifo` is usually the better primitive.

## Interfaces and Signal-Level Behavior

The interface should be defined around a specific crossing contract. The most reusable variants are usually handshake-based, because they are explicit and less likely to be misused than a pure "sample this stable bus" interface.

### Source-Side Signals

Typical source-domain signals:

- `src_clk`: source clock.
- `src_rst_n` or `src_reset`: source-domain reset.
- `src_data[DATA_WIDTH-1:0]`: bus value to transfer.
- `src_valid` or `src_req`: source indicates that a new bus value is ready.
- `src_ready` or `src_busy_n`: source-side backpressure or acceptance indication.

Behavioral expectations:

- The source must not change the logical value being transferred once a transfer is launched until the protocol allows release.
- If a handshake model is used, `src_valid` remains asserted or the data remains held stable until the transfer is accepted.
- If a snapshot model is used instead, the data stability window must be explicitly documented.

### Destination-Side Signals

Typical destination-domain signals:

- `dst_clk`: destination clock.
- `dst_rst_n` or `dst_reset`: destination-domain reset.
- `dst_data[DATA_WIDTH-1:0]`: coherently received word.
- `dst_valid`, `dst_pulse`, or `dst_update`: indicates a newly captured word.
- `dst_ready`: optional acknowledgment if the destination participates in a full handshake.

Behavioral expectations:

- The destination should only treat `dst_data` as newly updated when the destination-side update indication occurs.
- Between update events, `dst_data` may either hold the last delivered value or remain implementation-defined, but that behavior must be documented.
- If acknowledgments are exposed, they must be generated in the destination domain and safely returned to the source domain.

### Contract Variants

The library can reasonably support one or more of these contract styles:

#### Stable-Level Capture

- Source presents a value and guarantees it remains unchanged long enough.
- Destination samples the bus after a synchronized control indication or after observing a stable level.
- Lowest hardware overhead, but easiest to misuse.

#### Request/Acknowledge Handshake

- Source asserts a request with stable data.
- Destination captures the bus and acknowledges completion.
- Source releases or updates only after acknowledgment returns.
- Most robust and generally the preferred reusable option.

#### Toggle-Based Snapshot

- Source updates the bus, then toggles a control bit.
- Destination detects the synchronized toggle and captures the bus.
- Useful when a pulse could be missed but per-transfer queuing is not needed.

The chosen variant should be explicit in the RTL and in the top-level documentation, not left to guesswork.

## Parameters and Configuration Knobs

Important configuration parameters for `bus_synchronizer` generally include:

- `DATA_WIDTH`: width of the transferred bus.
- `SYNC_STAGES`: number of synchronizer stages for control signals crossing between domains.
- `HANDSHAKE_MODE`: selects stable-level, request/acknowledge, or toggle-based behavior if multiple variants share one wrapper.
- `RESET_VALUE`: optional destination-visible default value after reset.
- `OUTPUT_REG`: enables a registered destination output for timing or interface cleanliness.
- `SRC_HOLD_CHECK_EN`: optional simulation or assertion feature that checks source stability during transfer.
- `PULSE_MODE`: optional mode in which the destination exposes a one-cycle update strobe rather than level-valid semantics.

Recommended design direction:

- Make the safe path the default. A handshake-based variant is usually the best default because it constrains misuse.
- Keep control-signal synchronizers separate from the data path; data is protected by protocol stability, not by independently synchronizing every data bit.

## Internal Architecture and Dataflow

The internal architecture depends on the chosen crossing contract, but the general structure has three parts:

1. Source-side data holding logic.
2. CDC-safe control transfer.
3. Destination-side capture and optional acknowledgment path.

### Source-Side Holding Register

The source side typically loads the outgoing bus into a holding register when a transfer begins. This prevents the value from changing while the CDC control path is still in flight. Even if the functional source bus keeps evolving, the transferred snapshot remains fixed until completion.

### Control Synchronization

The key CDC event is usually a one-bit control signal:

- Request level.
- Request toggle.
- Acknowledge level.
- Acknowledge toggle.

That one-bit control signal is what passes through conventional flip-flop synchronizers. The multi-bit data bus does not pass through bitwise synchronizers because that would not preserve word coherence.

### Destination Capture

After the synchronized control event is recognized in the destination domain, the destination captures the held source bus into a destination register. The assumption that makes this legal is that the source has kept the bus stable for the entire transfer window.

### Optional Return Handshake

In a full handshake implementation, the destination returns a completion indication across the reverse CDC path. Once the source observes completion, it may clear the request or prepare the next word.

### Throughput Implication

Because the design usually waits for one control round trip or one stable capture interval per transferred word, this module trades throughput for simplicity and coherence. That is exactly why it belongs beside `pulse_synchronizer` and `async_fifo` rather than replacing either one.

## Clocking, Reset, CDC, and Timing Assumptions

The source and destination clocks are assumed to be asynchronous or unrelated enough that direct timing closure across domains is invalid.

Critical CDC assumptions:

- Only explicitly synchronized control signals should cross as raw single-bit CDC paths.
- The multi-bit bus is safe because it is held stable by protocol, not because the timing tools understand an arbitrary asynchronous data path.
- Synchronizer chains should be protected from retiming, logic absorption, or placement that undermines MTBF.

Reset guidance:

- Reset may be asynchronously asserted if required by system startup policy.
- Reset release should be synchronized per domain.
- Handshake state must return to an idle condition with no phantom transfer pending.
- Destination-visible output should reset to a documented value or remain invalid until the first successful transfer.

Timing and constraints guidance:

- Control synchronizer chains should be marked as CDC structures in synthesis and STA flows.
- False-path or asynchronous-clock-group constraints should be applied thoughtfully to CDC boundaries.
- If the data bus is held stable under handshake control, that assumption should be captured in documentation and, where possible, checked in simulation assertions.

## Latency, Throughput, and Resource Considerations

### Latency

Transfer latency is dominated by:

- Control-signal synchronization delay.
- Destination capture timing.
- Optional return-acknowledgment delay.

Even a simple request/acknowledge transfer may take several cycles in each domain before the source can issue another update. That is acceptable for control and status traffic but makes the primitive inappropriate for high-rate datapaths.

### Throughput

`bus_synchronizer` usually supports only one in-flight value at a time. Throughput is therefore limited by the handshake round-trip or the stability interval required for coherent capture.

As a rule of thumb:

- If the source can produce new values faster than the destination can accept completed snapshots, this module is the wrong primitive.
- If dropped intermediate values are acceptable and only the latest stable setting matters, a lighter stable-level synchronizer variant may be enough.

### Resource Use

The resource footprint is typically modest:

- A holding register for the source bus.
- A destination register for the received bus.
- Two or more control synchronizer chains.
- A small amount of source/destination FSM logic.

Compared with an asynchronous FIFO, this module is smaller and simpler, but its functional contract is much narrower.

## Verification Strategy

Verification should focus on coherence, handshake correctness, and misuse detection.

### Directed Tests

- Reset to idle and verify no false transfer indication occurs.
- Send a single word and verify the destination captures it exactly once.
- Send multiple words sequentially and verify each word is delivered in order.
- Exercise source attempts to update while busy and confirm that either backpressure or a documented ignore behavior occurs.
- Verify destination reset during or near a transfer does not deadlock the crossing.

### Randomized Tests

- Sweep unrelated source and destination clocks.
- Randomize transfer timing relative to both clocks.
- Randomize source stalls, destination stalls, and reset release ordering.
- Use a scoreboarding model that tracks expected delivered words under the chosen handshake semantics.

### Assertions

- Source-held data must remain stable while a transfer is outstanding.
- A transfer completion must correspond to exactly one destination update.
- No destination update may occur without a corresponding launched transfer.
- Busy/ready signaling must prevent overlapping launches if the module is single-entry.

### Misuse-Oriented Checks

This module benefits from simulation assertions that catch illegal use early:

- Detect source data changes during an active transfer.
- Detect transfer launches while the source is not ready.
- Detect unsupported source pulse widths if the protocol assumes minimum hold time.

Formal verification is also valuable for proving:

- No duplicate destination updates per source transaction.
- No lost transfer under legal protocol behavior.
- Eventual completion if both sides continue clocking and resets are not asserted.

## Integration Notes and Dependencies

`bus_synchronizer` is best used at clean control boundaries where the source of truth is obvious and transfer frequency is low.

Integration guidance:

- For software-programmed configuration, launch transfers only when registers commit, not on every raw bus write signal.
- For measurement export, consider whether only the latest sample matters or whether every sample must be preserved. If every sample matters, move to `async_fifo`.
- For mode and enable signals, bundle logically related control bits together so the destination sees one coherent update event.
- For debug status, decide whether level visibility or edge-triggered update notification is more useful to downstream consumers.

Dependencies and related blocks may include:

- `reset_synchronizer` for clean per-domain reset release.
- `pulse_synchronizer` for auxiliary one-bit events that accompany a bus update.
- `async_fifo` when traffic volume grows beyond single-entry transfer semantics.
- `register_slice` or local staging logic on either side when timing around the source or destination interface is tight.

One important integration rule is conceptual, not structural: do not use `bus_synchronizer` as a shortcut for any transfer that secretly has queueing requirements.

## Edge Cases, Failure Modes, and Design Risks

- Bitwise synchronizing a multi-bit bus without a coherence protocol is unsafe and should never be presented as equivalent to this module.
- A stable-level variant can be misused if the source changes the bus before the destination has safely captured it.
- Handshake implementations can deadlock if request and acknowledgment reset states are not defined carefully.
- Toggle-based schemes can fail if toggles are generated faster than the destination can observe them.
- If destination logic assumes every intermediate value is observed, but the source overwrites values before transfer completion, system behavior can be subtly wrong even when the module itself is functioning as specified.
- Source-held registers may capture transient internal values unless the launch point is aligned with a meaningful state boundary.
- During bring-up, this class of CDC bug often appears as rare wrong configuration words or impossible state encodings, which can be difficult to trace without assertions.

The main design risk is social as much as technical: `bus_synchronizer` looks simple, so teams may use it outside its legal operating envelope. The documentation and top-level interface should make the allowed use model unmistakable.

## Related Modules In This Domain

- `pulse_synchronizer`: preferred for one-bit control events when no multi-bit payload is needed.
- `async_fifo`: preferred for sustained or bursty multi-word transport.
- `stream_fifo`: preferred for same-clock elasticity.
- `register_slice`: preferred for same-domain timing cleanup.
- `timer_block` and `event_counter`: common producers of low-rate values that may cross domains through this module.

## Documentation Status

This `MODULE.md` defines the intended deep, domain-specific contract for the `bus_synchronizer` module in the Core RTL Infrastructure and Glue domain. Future RTL should either implement one clearly documented crossing method from this specification or narrow the document to the exact implemented contract.
