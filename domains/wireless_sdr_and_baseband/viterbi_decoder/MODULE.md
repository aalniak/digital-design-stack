# Viterbi Decoder

## Overview

Viterbi Decoder performs maximum-likelihood sequence estimation over a convolutional code trellis to reconstruct the transmitted bit stream from noisy coded symbols. It provides the inner decoding stage for many packet and continuous wireless systems.

## Domain Context

The Viterbi decoder is the classic hard- or soft-decision decoder for convolutionally coded wireless links. In many SDR and legacy baseband systems it is the main inner FEC engine that recovers payload bits from a trellis-coded stream after demodulation.

## Problem Solved

Convolutional coding only improves link reliability if the receiver can search the trellis efficiently and consistently. A dedicated Viterbi block centralizes branch metric computation, survivor selection, traceback, and decode confidence handling rather than scattering them across ad hoc logic.

## Typical Use Cases

- Decoding convolutionally coded packet payloads after soft demapping.
- Supporting SDR implementations of classic wireless and satellite waveforms.
- Evaluating BER versus soft-metric quantization in research testbeds.
- Providing corrected bit streams and error metrics to descrambling and framing logic.

## Interfaces and Signal-Level Behavior

- Inputs are coded bits or soft metrics with codeword or frame boundaries and optional puncturing control.
- Outputs provide decoded bits, validity markers, traceback latency information, and decode-status or metric summaries.
- Control registers configure constraint length, puncture pattern, traceback depth, and hard versus soft decision mode.
- Diagnostic outputs may expose path metrics, survivor memory status, and overflow indicators.

## Parameters and Configuration Knobs

- Constraint length and supported convolutional code rates.
- Soft-metric width and normalization policy.
- Traceback depth and survivor memory organization.
- Optional puncturing and depuncturing support.

## Internal Architecture and Dataflow

A Viterbi decoder typically consists of branch-metric units, add-compare-select stages, survivor memory, and traceback logic. The domain contract should document latency and frame-boundary handling carefully because decoded bits emerge delayed relative to coded input and puncturing changes the branch interpretation.

## Clocking, Reset, and Timing Assumptions

The decoder assumes the incoming coded stream follows the configured trellis and puncturing pattern exactly. Reset clears survivor memory and path metrics. If tail bits or tail-biting modes are supported, the frame-start and frame-end semantics must be explicit.

## Latency, Throughput, and Resource Considerations

Resource use can be high because ACS arrays and survivor memory scale with trellis complexity and throughput. Latency is dominated by traceback depth, but sustained throughput still needs to match the coded symbol rate for real-time reception. Soft metrics generally improve performance at additional cost.

## Verification Strategy

- Compare decoded output against a trusted convolutional-code reference for hard and soft inputs.
- Inject channel errors, punctured streams, and tail conditions to verify correction capability.
- Check traceback latency and frame-boundary behavior under streaming traffic.
- Measure fixed-point metric normalization behavior to ensure no hidden overflow corrupts decoding.

## Integration Notes and Dependencies

Viterbi Decoder typically follows demapping, depuncturing, and deinterleaving, then feeds Descrambler and Framer or Deframer logic. It should align with the configured convolutional encoder on rate, puncturing, and termination rules.

## Edge Cases, Failure Modes, and Design Risks

- A mismatch in puncturing or termination policy can make the decoder fail intermittently in ways that resemble random channel loss.
- Undocumented decode latency can break downstream packet framing.
- Poor path-metric normalization may only fail under long noisy packets, making the issue hard to spot.

## Related Modules In This Domain

- convolutional_encoder
- reed_solomon_codec
- deinterleaver
- descrambler

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Viterbi Decoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
