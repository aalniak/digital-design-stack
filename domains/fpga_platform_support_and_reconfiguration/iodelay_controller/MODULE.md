# IODELAY Controller

## Overview

IODELAY Controller manages calibration and readiness of FPGA input or output delay resources and exposes delay-resource status to the rest of the platform. It provides a stable control surface for FPGA delay-line infrastructure.

## Domain Context

IODELAY control is the FPGA-specific calibration and management layer around delay elements used for source-synchronous interfaces and timing centering. In this domain it exists because delay resources must be initialized and, on some families, actively calibrated before data capture is trustworthy.

## Problem Solved

Many high-speed or source-synchronous interfaces depend on delay elements that are unusable until calibrated. A dedicated controller keeps the primitive-specific calibration and ready semantics out of every user of those delays.

## Typical Use Cases

- Bringing up source-synchronous interfaces that depend on IDELAY or ODELAY primitives.
- Providing ready status to DDR or sensor interfaces that center sampling windows.
- Abstracting family-specific delay calibration rules.
- Supporting delay-resource reinitialization after reconfiguration or clock changes.

## Interfaces and Signal-Level Behavior

- Inputs include reference clock, reset, optional recalibration request, and primitive-specific status where needed.
- Outputs provide ready or calibrated indications and optional control signals for associated delay resources.
- Control interfaces configure startup calibration policy and, if supported, recalibration behavior.
- Status signals may expose calibration_active, calibration_fail, and reference_invalid indications.

## Parameters and Configuration Knobs

- Target FPGA primitive family or delay-resource type.
- Reference clock selection and expected calibration timing.
- Global versus per-bank control style.
- Automatic versus software-triggered recalibration support.

## Internal Architecture and Dataflow

The controller usually instantiates or wraps vendor calibration primitives and conditions their status for downstream logic. The key contract is when user logic may trust delay elements and whether recalibration temporarily invalidates timing on live interfaces.

## Clocking, Reset, and Timing Assumptions

The block assumes the supplied reference clock meets vendor calibration requirements. Reset clears ready status until calibration completes. If recalibration is supported in-system, the downstream interface quiesce or retraining requirements must be explicit.

## Latency, Throughput, and Resource Considerations

Area is small, but system impact is large because a false-ready condition can undermine whole interfaces. The main tradeoff is between a simple one-shot startup controller and more dynamic recalibration support for drifting conditions.

## Verification Strategy

- Verify ready assertion only after modeled calibration completion.
- Stress reset, missing reference clock, and recalibration requests.
- Check integration with interfaces that wait on the ready signal.
- Validate behavior on real hardware where vendor primitive timing may differ from ideal simulation.

## Integration Notes and Dependencies

IODELAY Controller typically feeds Startup Sequencer, DDR PHY Wrapper, and source-synchronous I/O logic. It should align with family-specific tool constraints and delay-bank organization.

## Edge Cases, Failure Modes, and Design Risks

- A premature ready signal can create intermittent capture failures that look like random link noise.
- Recalibration on active interfaces can be disruptive if not coordinated carefully.
- Vendor-family assumptions are easy to hardcode incorrectly and then reuse on incompatible parts.

## Related Modules In This Domain

- startup_sequencer
- ddr_phy_wrapper
- mmcm_pll_wrapper
- vendor_ram_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the IODELAY Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
