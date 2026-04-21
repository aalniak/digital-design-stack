# Wakeup Controller

## Overview

wakeup_controller arbitrates and qualifies the events that are allowed to bring a low-power or gated domain back to an active state. It is the event-facing companion to power-domain sequencing.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

A sleeping system often has many possible wake sources, but not every event should wake every domain. The design needs one place to mask, debounce, prioritize, and record wake causes.

## Typical Use Cases

- Wake a domain on timer expiry, external pin, or software command.
- Qualify noisy external wake events before expensive bring-up.
- Record which source caused the most recent wake.

## Interfaces and Signal-Level Behavior

- Inputs include raw wake sources, enable masks, debounce controls, and optional domain-state feedback.
- Outputs include wake request to the power controller plus cause or vector information.
- Control plane signals may clear latched causes or configure per-source behavior.

## Parameters and Configuration Knobs

- NUM_SOURCES sets wake-source count.
- DEBOUNCE_EN enables filtering.
- STICKY_CAUSE_EN preserves wake reason until cleared.
- SOURCE_PRIORITY_MODE selects ordering when many wakes arrive together.
- AUTO_CLEAR_POLICY defines when pending wake state is released.

## Internal Architecture and Dataflow

The module usually conditions incoming sources, applies masks, latches a wake cause, and issues a domain wake request. Strong designs separate raw event observation from wake eligibility policy.

## Clocking, Reset, and Timing Assumptions

wakeup_controller usually lives in an always-on domain. Any asynchronous sources must be synchronized safely into that domain. Reset should define how level-sensitive wake sources behave immediately after startup.

## Latency, Throughput, and Resource Considerations

Wake latency matters more than throughput. More filtering improves robustness but delays response. Logic cost scales mostly with source count and filtering depth.

## Verification Strategy

- Check masking, filtering, and cause-latching for each source.
- Verify simultaneous wake events follow the documented priority rule.
- Exercise transitions among sleep, waking, and active states.
- Confirm software clear does not erase an active level wake that should remain pending.

## Integration Notes and Dependencies

wakeup_controller typically feeds power_domain_controller and consumes timer, interrupt-like, and external events. It should own wake-cause visibility so software can diagnose why a domain resumed.

## Edge Cases, Failure Modes, and Design Risks

- Vague cause-latching policy creates software-visible race conditions.
- Debounce that is too aggressive can hide legitimate wake events.
- Unsynchronized wake sources can create metastability precisely when the rest of the system is least observable.

## Related Modules In This Domain

- power_domain_controller
- timer_block
- retention_controller
- clock_gating_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Wakeup Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
