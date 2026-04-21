# Scan Controller

## Overview

Scan Controller sequences scan enable, capture, shift, and chain selection behavior for internal scan infrastructure. It provides coordinated control over structural scan test operation.

## Domain Context

The scan controller orchestrates internal scan chains for structural test, shifting, capture, and mode control. In this domain it is the bridge between external test intent and the many distributed scan elements inserted throughout the design.

## Problem Solved

Large designs contain many scan elements and often several scan chains or compression domains. A dedicated controller keeps capture and shift timing, chain activation, and functional isolation explicit instead of scattering control signals across the design.

## Typical Use Cases

- Driving structural scan test during manufacturing.
- Selecting among internal scan chains or scan partitions.
- Coordinating scan capture and shift relative to clocks and resets.
- Providing a reusable scan-control point under JTAG or test-mode control.

## Interfaces and Signal-Level Behavior

- Inputs include TAP instruction-derived control, test clocks, scan-mode requests, and chain-selection metadata.
- Outputs provide scan_enable, capture_pulse, shift_control, and chain-select signals to internal scan infrastructure.
- Control interfaces may configure scan partitions, compression enable, and safe clocking policy.
- Status signals can expose scan_active, chain_ready, and illegal_test_mode conditions.

## Parameters and Configuration Knobs

- Number of scan chains or partitions.
- Support for compressed or uncompressed scan modes.
- Capture and shift timing policy.
- Clock-domain partition awareness if scan spans several functional domains.

## Internal Architecture and Dataflow

The controller usually contains a test-mode state machine, chain-selection logic, clock-control coordination, and safety gating to prevent accidental functional interaction. The architectural contract should define how scan operations interact with functional clocks and resets, because that is where structural-test bugs often become silicon bring-up pain.

## Clocking, Reset, and Timing Assumptions

The block assumes test clocks and scan paths are provisioned consistently with the design insertion flow. Reset should cleanly exit scan mode and restore functional behavior. If some domains require special isolation or clock sequencing, that responsibility should be visible here rather than implicit elsewhere.

## Latency, Throughput, and Resource Considerations

Scan control is not throughput critical in the usual sense, but robust coordination across large scan infrastructure is essential. Area is modest. The main tradeoff is between a simple controller and support for richer multi-domain or compressed-scan flows.

## Verification Strategy

- Exercise capture, shift, and update sequencing across all supported scan modes.
- Verify clean entry to and exit from scan mode relative to functional clocks and resets.
- Check chain selection and illegal mode combinations.
- Run end-to-end structural testbench sequences with representative attached scan chains.

## Integration Notes and Dependencies

Scan Controller is typically driven from JTAG TAP and coordinates with Boundary Scan, MBIST, LBIST, and scan-inserted design logic. It should align with DFT insertion assumptions and manufacturing test programs.

## Edge Cases, Failure Modes, and Design Risks

- A controller that mishandles scan entry or exit can leave parts of the design in an undefined functional state.
- Cross-domain scan coordination issues often appear only late in silicon test.
- Underdocumented chain-selection policy makes manufacturing test harder to debug and maintain.

## Related Modules In This Domain

- jtag_tap
- boundary_scan_wrapper
- mbist_controller
- lbist_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Scan Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
