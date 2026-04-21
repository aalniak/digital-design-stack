# TRNG Block

## Overview

TRNG Block collects entropy from physical noise sources, performs health monitoring and conditioning, and emits trusted entropy words or seed material for secure consumers. It is the hardware entropy anchor beneath DRBGs and secure-random services.

## Domain Context

The true random number generator is the entropy root of the secure subsystem. It transforms physical noise into conditioned entropy suitable for seeding deterministic generators, provisioning secrets, and powering protocols that need unpredictability not derivable from prior digital state.

## Problem Solved

Cryptographic security depends critically on unpredictable seeds and nonces, but many digital designs are tempted to treat counters or weak ring-oscillator outputs as enough. A dedicated TRNG makes entropy-source assumptions, health tests, and output readiness explicit instead of implicit.

## Typical Use Cases

- Seeding DRBG instances for ongoing cryptographic-random service.
- Generating high-value entropy during provisioning or key creation.
- Supporting challenge material or device-unique initialization flows.
- Providing a measurable entropy-health interface for security diagnostics and compliance work.

## Interfaces and Signal-Level Behavior

- Inputs may include enable, sample window controls, health-test configuration, and optional environmental or clock gating controls for the entropy source.
- Outputs provide entropy words, entropy_valid, health status, and fatal or recoverable fault indications.
- Control interfaces configure startup tests, conditioning mode, output batching, and consumer routing.
- Status signals often expose seeded, health_fail, repetition_test_fail, and source_unstable indications.

## Parameters and Configuration Knobs

- Entropy-source count or type, such as ring-oscillator banks or metastability samplers.
- Conditioning policy and output word width.
- Startup and continuous health-test options.
- Maximum batch size or backpressure buffering before entropy is consumed downstream.

## Internal Architecture and Dataflow

A TRNG Block usually combines one or more entropy sources, raw-sample collection, health tests, optional conditioning or whitening, and controlled output release. The architectural contract should define clearly whether the output is raw noise, conditioned entropy, or merely seed-quality input for a DRBG, because downstream trust assumptions differ sharply between those categories.

## Clocking, Reset, and Timing Assumptions

The block assumes its physical entropy sources are implemented and laid out in a manner suitable for the target process, voltage, and temperature range. Reset should rerun startup health checks or invalidate entropy-ready status until those checks complete. If factory test modes expose raw entropy-source behavior, those modes should be strictly lifecycle-gated.

## Latency, Throughput, and Resource Considerations

Raw throughput depends on the entropy source and health-test policy, and it is usually far lower than DRBG output rates. The meaningful performance metric is entropy quality and continuous health confidence, not megabytes per second. Latency during startup and recovery after health failure often matters more than steady-state bandwidth.

## Verification Strategy

- Verify startup and continuous health-test behavior, including correct failure latching and recovery policy.
- Check conditioning and output framing against the documented entropy-quality contract.
- Stress backpressure and consumer bursts so entropy is never duplicated or stale across requests.
- Validate zeroization or disable behavior during tamper, lifecycle, or reset transitions.

## Integration Notes and Dependencies

TRNG Block feeds DRBG Block and occasionally high-value provisioning or attestation flows directly. It should integrate with Tamper Monitor, lifecycle controls, and clock or power management carefully, because entropy quality can degrade under abnormal operating conditions even when digital logic still appears correct.

## Edge Cases, Failure Modes, and Design Risks

- Calling conditioned seed-quality output full application-ready random data without explanation can mislead consumers badly.
- Health tests that are present but easy to bypass are nearly as bad as no tests at all.
- Debug or characterization access to raw entropy sources must be tightly controlled or removed in production.

## Related Modules In This Domain

- drbg_block
- tamper_monitor
- key_ladder
- puf_interface

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the TRNG Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
