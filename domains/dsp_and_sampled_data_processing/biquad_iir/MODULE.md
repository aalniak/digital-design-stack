# Biquad IIR Filter

## Overview

The biquad IIR filter implements a second-order recursive filter section suitable for equalization, tone shaping, resonators, and control-oriented filtering. Cascaded biquads are often the preferred hardware form for moderate-order IIR responses because their coefficient structure is compact and well understood.

## Domain Context

DSP and sampled-data processing modules operate on numerically structured streams where timing regularity, coefficient interpretation, and spectral behavior matter as much as raw logic correctness. In this domain the most important documentation themes are fixed-point scaling, streaming cadence, filter state management, latency, and how algorithmic intent maps onto hardware structure.

## Problem Solved

Many useful filter responses are inefficient to realize as long FIRs, especially when low-order poles or narrow notches are needed. A biquad section offers those responses compactly, but recursive state and coefficient quantization require careful handling. This module makes the section behavior explicit and reusable.

## Typical Use Cases

- Building audio equalizers, tone controls, and crossover filters.
- Implementing control-loop or sensor-conditioning filters with low latency.
- Cascading several sections to realize higher-order IIR responses in a structured way.

## Interfaces and Signal-Level Behavior

- Input side accepts scalar samples with ready-valid timing or fixed-rate sample strobes.
- Coefficient side loads numerator and denominator coefficients and may support safe section updates at frame boundaries.
- Output side emits filtered samples and optionally exposes internal state for debug or calibration.

## Parameters and Configuration Knobs

- Data width, coefficient width, section structure such as Direct Form I or II, and rounding mode.
- Internal accumulator width, saturation policy, and number of cascaded sections if wrapped in a bank.
- Coefficient reload mode and state reset behavior.

## Internal Architecture and Dataflow

The section computes each output from current and past inputs plus past outputs weighted by the configured coefficients. Hardware designs often choose a transposed direct form for better numerical behavior and pipeline placement. Internal state registers capture delayed terms, while a multiply-accumulate path forms the new sample each cycle or each accepted strobe.

## Clocking, Reset, and Timing Assumptions

IIR stability depends on coefficient choice and fixed-point precision, so the module contract should make it clear that not every coefficient set is safe. Reset policy matters because recursive state initialization changes startup transients noticeably.

## Latency, Throughput, and Resource Considerations

Biquads offer low filter order per multiplier compared with equivalent FIR responses, but they can be more sensitive to quantization. Throughput is usually one sample per cycle in fully parallel form or lower if coefficients are time-multiplexed.

## Verification Strategy

- Compare impulse, step, and frequency responses against a floating-point reference across representative coefficient sets.
- Check stability and saturation behavior under large inputs and poorly scaled coefficients.
- Verify coefficient updates and reset handling do not corrupt internal recursive state unexpectedly.

## Integration Notes and Dependencies

Biquads often live in banks, EQ chains, or control paths where coefficient provenance matters. Integrators should store coefficient formats and design tools alongside the module so future updates do not rely on guesswork.

## Edge Cases, Failure Modes, and Design Risks

- A numerically valid floating-point design can become unstable after coefficient quantization.
- Recursive overflow may manifest as strange tones or bias rather than obvious arithmetic failure.
- Partial coefficient updates across numerator and denominator terms can produce a transient unstable filter.

## Related Modules In This Domain

- fir_filter
- dc_blocker
- agc_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Biquad IIR Filter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
