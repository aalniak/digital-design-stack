# DDR PHY Wrapper

## Overview

DDR PHY Wrapper encapsulates vendor or custom DDR PHY resources, training controls, and initialization status behind a normalized memory-interface contract. It provides the platform-specific boundary around external DDR timing and calibration logic.

## Domain Context

A DDR PHY wrapper packages the board- and vendor-specific interface around external memory training, calibration, and I/O timing into a cleaner subsystem boundary. In this domain it is the hardware shell that makes external DDR memory look like a managed service rather than a collection of fragile primitives.

## Problem Solved

DDR PHY logic is highly device- and board-dependent, with many training and calibration subtleties. A dedicated wrapper confines that complexity so the rest of the design sees stable readiness, interface width, and maintenance semantics.

## Typical Use Cases

- Integrating external DDR memory on an FPGA platform.
- Abstracting vendor MIG or custom PHY-specific details behind a local interface.
- Coordinating memory readiness with global startup sequencing.
- Providing a controlled point for retraining, status, and error reporting.

## Interfaces and Signal-Level Behavior

- Inputs include memory-side command or data transactions, resets, clocks, and optional retrain or calibration controls.
- Outputs provide memory transaction responses, ready or calibrated status, and error or training-state metadata.
- Control interfaces configure initialization or training flow and optional maintenance operations.
- Status signals may expose init_done, training_fail, and calibration_active conditions.

## Parameters and Configuration Knobs

- Target DDR type and interface width.
- Native user-interface width and command protocol.
- Retraining support and calibration policy.
- ECC support or pass-through behavior if applicable.

## Internal Architecture and Dataflow

The wrapper usually instantiates vendor memory-interface IP or custom PHY control and then normalizes status, reset, and user-interface semantics. The key contract is exactly when memory traffic is legal relative to init_done and what retraining or error conditions mean to upstream logic.

## Clocking, Reset, and Timing Assumptions

The module assumes board timing, pin constraints, and clocking match the PHY configuration. Reset should place the memory interface in a quiescent unready state until training completes. If retraining can invalidate data traffic in-system, that disruption must be documented clearly.

## Latency, Throughput, and Resource Considerations

The wrapper itself is not the bandwidth limiter so much as the interface around training, refresh, and user-side adaptation. The most important performance characteristics are readiness latency, sustained interface width, and clear failure reporting on training problems.

## Verification Strategy

- Verify init_done and training status semantics against the chosen PHY IP or model.
- Stress reset, failed training, and optional retrain flows.
- Check user-interface transaction legality before and after readiness.
- Run memory traffic tests on hardware to confirm wrapper assumptions hold beyond simulation.

## Integration Notes and Dependencies

DDR PHY Wrapper works with Startup Sequencer, MMCM/PLL Wrapper, and memory-facing caches or DMA blocks. It should align with board constraints and memory controller expectations so no user logic assumes DDR availability too early.

## Edge Cases, Failure Modes, and Design Risks

- Treating PHY ready as a generic clock-good signal rather than a strict traffic permission can corrupt memory accesses.
- Tool- or board-specific assumptions can quietly invalidate an otherwise generic wrapper.
- Retrain or calibration events in the field need clear software and hardware coordination or data integrity may suffer.

## Related Modules In This Domain

- startup_sequencer
- mmcm_pll_wrapper
- iodelay_controller
- vendor_ram_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the DDR PHY Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
