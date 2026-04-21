# ECC Scrubber

## Overview

ECC Scrubber periodically scans ECC-protected storage, detects and corrects correctable errors, and optionally rewrites corrected data back to memory. It provides proactive maintenance of memory integrity in long-lived systems.

## Domain Context

ECC scrubbing is the background maintenance process that reads protected storage, corrects latent single-bit errors, and rewrites clean data before faults accumulate. In this domain it is the quiet reliability engine that reduces the chance of multi-bit escalation over time.

## Problem Solved

ECC alone only helps at the moment of access. If corrected soft errors are never rewritten, they can accumulate into uncorrectable multi-bit faults. A dedicated scrubber makes maintenance policy and reporting explicit.

## Typical Use Cases

- Refreshing ECC-protected SRAM or memory arrays in safety-critical products.
- Reducing latent fault accumulation in radiation-prone or long-uptime systems.
- Providing periodic health statistics on corrected memory errors.
- Supporting online maintenance without relying on normal software access patterns.

## Interfaces and Signal-Level Behavior

- Inputs include scrub start or schedule control, target memory selection, and ECC decode status from the memory path.
- Outputs provide scrub progress, corrected-error counts, rewrite requests, and uncorrectable-fault indications.
- Control interfaces configure scrub rate, address range, and pause or throttle policy.
- Status signals may expose scrub_active, corrected_rewrite_done, and uncorrectable_detected conditions.

## Parameters and Configuration Knobs

- Target memory range and address width.
- Scrub interval or bandwidth limit.
- Correctable-versus-uncorrectable event handling policy.
- Support for several protected memories or banks.

## Internal Architecture and Dataflow

The scrubber generally sequences background reads, invokes or observes ECC decode, and triggers rewrite of corrected words while tracking statistics. The architectural contract should define whether it uses the same access path as functional traffic or a private maintenance path, because contention and coherence behavior depend on that choice.

## Clocking, Reset, and Timing Assumptions

The block assumes memory contents may be read and, if needed, rewritten safely under the chosen system policy. Reset typically restarts the scrub schedule or leaves progress undefined until rescheduled. If functional accesses can race with scrub writes, the arbitration and coherence policy must be explicit.

## Latency, Throughput, and Resource Considerations

Scrubbing trades memory bandwidth for reliability margin. The main design question is how aggressively to scrub without perturbing real-time workloads. Area is modest, but background bandwidth and interaction with memory arbiters matter a great deal.

## Verification Strategy

- Inject correctable and uncorrectable ECC faults into representative memory models.
- Verify rewrite behavior only occurs for correctable words and is counted accurately.
- Stress arbitration with concurrent functional traffic.
- Check scrub-rate throttling and progress reporting over long address ranges.

## Integration Notes and Dependencies

ECC Scrubber works with SECDED, BCH, or memory-wrapper ECC paths and often reports into Error Logger or Safe State logic on severe faults. It should align with software maintenance policy so background correction does not surprise system services.

## Edge Cases, Failure Modes, and Design Risks

- A scrubber that rewrites stale or raced data can hurt reliability instead of helping it.
- Too-slow scrub cadence may give little benefit in harsh environments.
- If corrected-error counts are not exposed clearly, aging or radiation trends remain invisible.

## Related Modules In This Domain

- hamming_secded
- bch_codec
- error_logger
- safe_state_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the ECC Scrubber module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
