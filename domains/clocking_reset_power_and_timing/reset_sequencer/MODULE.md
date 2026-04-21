# Reset Sequencer

## Overview

reset_sequencer orchestrates the order and timing by which several resets are asserted and released across a subsystem. It is the policy layer above per-domain reset synchronization.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

Complex systems rarely have only one reset. Different blocks need ordered release once clocks, power, or lock conditions are ready. reset_sequencer makes that ordering explicit.

## Typical Use Cases

- Release memory, interconnect, and processor logic in a defined order.
- Hold selected blocks in reset until prerequisites are met.
- Support local or partial recovery after a fault.

## Interfaces and Signal-Level Behavior

- Inputs commonly include global reset request, lock or power-good signals, and optional software controls.
- Outputs drive one or more downstream reset requests.
- Status may expose current phase, ready state, or timeout fault.

## Parameters and Configuration Knobs

- NUM_RESETS sets the number of controlled outputs.
- SEQUENCE_DELAYS define inter-reset spacing.
- DEPENDENCY_MODE enables prerequisite conditions.
- TIMEOUT_EN raises a fault when a prerequisite never arrives.
- PARTIAL_RECOVERY_EN supports subset re-entry.

## Internal Architecture and Dataflow

The sequencer is usually an FSM with timers and condition checks. It asserts resets, waits for prerequisites, then releases outputs in a defined order, often through local reset synchronizers.

## Clocking, Reset, and Timing Assumptions

The sequencer itself normally lives in a stable supervisory clock domain. Its outputs are about policy and ordering, not local deassertion cleanliness. Reset defaults should be conservative.

## Latency, Throughput, and Resource Considerations

The key metrics are bounded startup latency and correctness, not throughput. The hardware cost is low compared with the system impact of sequencing mistakes.

## Verification Strategy

- Check nominal startup and fault-recovery paths.
- Verify timeouts when prerequisites never assert.
- Exercise repeated reset requests and re-entry during sequencing.
- Confirm order and spacing between every controlled reset.

## Integration Notes and Dependencies

reset_sequencer should coordinate with lock monitors, power-domain control, and reset synchronizers. It is often the backbone of SoC bring-up policy.

## Edge Cases, Failure Modes, and Design Risks

- Releasing reset before clocks are trustworthy can corrupt downstream initialization.
- Too much hidden reset behavior in leaf blocks can conflict with the top-level sequence.
- Poor observability makes bring-up failures hard to diagnose.

## Related Modules In This Domain

- reset_synchronizer
- pll_lock_monitor
- power_domain_controller
- clock_fail_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Reset Sequencer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
