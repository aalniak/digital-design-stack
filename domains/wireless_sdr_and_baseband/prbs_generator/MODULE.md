# PRBS Generator

## Overview

The PRBS generator creates deterministic pseudo-random binary sequences for test, scrambling support, channel probing, or built-in self-check paths. It is a utility block that appears across communication and validation flows.

## Domain Context

Wireless, SDR, and baseband modules translate between sampled waveforms, coded bits, and protocol frames in communication systems. In this domain the most important documentation topics are symbol and bit ordering, framing boundaries, soft-versus-hard metric semantics, channel assumptions, and whether a block belongs on the transmit path, receive path, or both.

## Problem Solved

Many verification and link-validation tasks need known long pseudo-random sequences with precise polynomial and reset behavior. This module provides that sequence source so different parts of the system do not implement incompatible versions.

## Typical Use Cases

- Generating test payloads and stress patterns for links and modem paths.
- Providing reference sequences for built-in BER measurement or scrambler alignment.
- Supporting reusable pseudo-random stimulus in SDR validation flows.

## Interfaces and Signal-Level Behavior

- Control side selects polynomial profile, seed, run length, and enable behavior.
- Output side emits PRBS bits or words with documented bit ordering and valid timing.
- Optional status side exposes internal state or repetition markers for debug and synchronization.

## Parameters and Configuration Knobs

- Polynomial selection, state width, output width per cycle, and seed programmability.
- Bit ordering, runtime profile switching, and optional lockstep repeat behavior.
- Enable, pause, and reset semantics.

## Internal Architecture and Dataflow

The generator advances an LFSR or equivalent pseudo-random state according to the chosen polynomial and emits one or more bits per cycle in the documented order. The contract should define whether outputs are serial, parallelized, or byte-packed and how resets affect phase relative to any checker or external reference.

## Clocking, Reset, and Timing Assumptions

Sequence meaning depends on the exact polynomial, seed, and bit order, so those assumptions must remain visible. Reset should place the generator in a documented initial state rather than an arbitrary all-zero illegal state unless that is explicitly supported.

## Latency, Throughput, and Resource Considerations

The generator is lightweight and can usually sustain high throughput with minimal logic. Resource use is small and dominated by the state register and XOR taps.

## Verification Strategy

- Compare emitted sequences against a reference PRBS implementation for each supported polynomial profile.
- Check seed loading, bit ordering, and reset or pause behavior.
- Verify that parallel output grouping preserves the documented serial sequence order.

## Integration Notes and Dependencies

This block often pairs with BER checkers, scramblers, and lab test harnesses, so its profile naming and phase conventions should be documented with those consumers. Integrators should also note whether it is allowed in production data paths or only in test modes.

## Edge Cases, Failure Modes, and Design Risks

- A bit-order mismatch can make a valid PRBS source look broken to a checker.
- Loading an illegal all-zero state without a documented recovery rule may stall the sequence.
- Profile switches without clear boundaries can produce ambiguous test results.

## Related Modules In This Domain

- scrambler
- descrambler
- correlator_bank

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PRBS Generator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
