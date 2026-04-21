# Clock Gating Wrapper

## Overview

clock_gating_wrapper encapsulates safe clock gating behavior behind one reusable interface. Its job is to hide platform-specific gating details while keeping enable, bypass, and test behavior explicit.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

Directly gating clocks with ordinary logic is unsafe and inconsistent across flows. clock_gating_wrapper gives the stack one place to express safe gating intent.

## Typical Use Cases

- Reduce dynamic power in idle subsystems.
- Provide a standard gated-clock control around a managed domain.
- Expose test or scan bypass without duplicating gating policy.

## Interfaces and Signal-Level Behavior

- Inputs usually include source clock, gate request, and test or bypass override.
- Output is a gated clock or a documented platform-safe equivalent.
- Status may indicate accepted gate state or override condition.

## Parameters and Configuration Knobs

- ACTIVE_HIGH_ENABLE defines polarity.
- TEST_BYPASS_EN supports scan or debug override.
- TECH_CELL or MODE selects the target gating style.
- ENABLE_SYNC_EN adds local synchronization for the request.
- FPGA_SAFE_MODE substitutes a clock-enable style realization where needed.

## Internal Architecture and Dataflow

ASIC-oriented implementations often wrap a proper integrated clock-gating cell. FPGA-oriented ones may instead keep the physical clock free-running and express the same policy through enables. The wrapper keeps the contract stable while the physical realization varies.

## Clocking, Reset, and Timing Assumptions

The source clock is already valid. Enable changes must either meet primitive timing assumptions or be synchronized locally. Startup policy should define whether the domain begins enabled or held off.

## Latency, Throughput, and Resource Considerations

Functional latency is negligible, but the system-level effect on skew, insertion delay, and downstream sequencing is significant. The logic footprint is tiny compared with the clocking consequences.

## Verification Strategy

- Check gating and ungating for spurious pulses.
- Verify test bypass overrides normal gating.
- Confirm synthesis maps to the intended primitive or safe style.
- Exercise gate control around reset and low-power transitions.

## Integration Notes and Dependencies

clock_gating_wrapper should be coordinated with power_domain_controller, wakeup_controller, and reset sequencing. It is not only a power block; it is part of domain coherency.

## Edge Cases, Failure Modes, and Design Risks

- A plain logic gate in place of a proper primitive is a catastrophic mistake.
- ASIC and FPGA assumptions differ sharply.
- Gating without coordinating reset or retention can leave downstream logic incoherent.

## Related Modules In This Domain

- power_domain_controller
- retention_controller
- wakeup_controller
- clock_mux_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Clock Gating Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
