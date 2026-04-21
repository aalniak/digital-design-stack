# Nav Bit Synchronizer

## Overview

Nav Bit Synchronizer determines the symbol timing and polarity needed to recover navigation bits from tracked GNSS channel correlations. It turns coherent channel outputs into a framed bit stream suitable for message decoding.

## Domain Context

Navigation-bit synchronization bridges raw tracking and message decoding. Once a GNSS channel is tracking code and carrier, the receiver still needs to identify symbol boundaries and recover the navigation data stream that carries timing, orbital, and system information.

## Problem Solved

Carrier and code lock do not automatically reveal where navigation-bit transitions occur. Without a dedicated synchronizer, bit edges may be misdetected, long coherent integrations may cross symbol boundaries incorrectly, and message decoders will struggle with preventable framing errors.

## Typical Use Cases

- Recovering navigation data bits from tracked satellite channels.
- Finding symbol boundaries needed before ephemeris and time message decoding.
- Supporting coherent integration management that respects navigation-bit sign changes.
- Monitoring channel health by tracking bit error and sync stability metrics.

## Interfaces and Signal-Level Behavior

- Inputs usually include prompt I/Q or soft symbol estimates, code epoch markers, and channel lock status.
- Outputs provide bit decisions, symbol boundary markers, sync-valid flags, and possibly soft metrics.
- Control registers set integration span, polarity conventions, and search or confirmation thresholds.
- Diagnostic outputs may expose boundary hypotheses, sign stability, and bit confidence indicators.

## Parameters and Configuration Knobs

- Supported symbol period hypotheses and accumulation depth.
- Hard versus soft output format and confidence width.
- Thresholds for declaring sync acquired or lost.
- Optional assistance from known secondary-code or data-channel structure.

## Internal Architecture and Dataflow

Typical structure includes symbol accumulation, edge-hypothesis testing, boundary confirmation, and bit decision logic. The contract should define whether outputs are fully synchronized bits, tentative soft symbols, or only boundary markers so downstream decoders know how much framing work remains.

## Clocking, Reset, and Timing Assumptions

The synchronizer assumes code and carrier loops are stable enough that sign changes caused by data can be observed coherently. Reset clears boundary state and confidence history. If secondary codes or pilot/data channel separation are involved, those assumptions need to be explicit.

## Latency, Throughput, and Resource Considerations

Computation is light, but robustness depends on coherent accumulation strategy and confirmation logic. Latency is inherently tied to symbol duration and confirmation dwell, making honest sync-valid signaling more important than instant declaration.

## Verification Strategy

- Inject channels with known bit boundaries and confirm acquisition of correct symbol timing.
- Stress low-SNR and sign-inverted cases to verify polarity handling.
- Check loss-of-sync and reacquisition behavior under temporary fades.
- Compare decoded bit stream and boundary markers against a software receiver reference.

## Integration Notes and Dependencies

Nav Bit Synchronizer follows the tracking loops and feeds Ephemeris Decoder and channel diagnostics. It should also align with integration policy in the tracking loops so bit transitions do not invalidate coherent accumulations unexpectedly.

## Edge Cases, Failure Modes, and Design Risks

- Misidentified symbol boundaries can poison message decoding while leaving tracking seemingly healthy.
- If soft versus hard decision semantics are unclear, downstream decoders may use the data incorrectly.
- Slow loss-of-sync detection can make bad navigation words persist too long.

## Related Modules In This Domain

- carrier_tracking_pll
- ephemeris_decoder
- pseudorange_engine
- carrier_phase_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Nav Bit Synchronizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
