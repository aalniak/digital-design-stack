# Fault Injector

## Overview

Fault Injector deliberately injects configured faults or error conditions into selected subsystems for validation, robustness testing, or safety diagnostics. It provides controlled perturbation of system behavior for test and analysis.

## Domain Context

Fault injection logic is a validation and safety-analysis aid used to exercise error paths deliberately. In this domain it gives engineers a controlled way to force protocol faults, ECC errors, timeout conditions, or safety events without relying on rare natural occurrence.

## Problem Solved

Robust fault handling is difficult to validate if faults cannot be reproduced on demand. A dedicated injector makes injection points, duration, and scope explicit so negative testing is systematic instead of ad hoc.

## Typical Use Cases

- Forcing ECC, timeout, or protocol-error scenarios during validation.
- Exercising safe-state and alarm paths for safety analysis.
- Supporting field diagnostics or factory screening in carefully controlled modes.
- Benchmarking fault coverage and recovery behavior across subsystems.

## Interfaces and Signal-Level Behavior

- Inputs include injection commands, target selectors, trigger timing, and optional authorization or lifecycle mode.
- Outputs provide injected fault control signals and completion or status reporting.
- Control interfaces configure fault type, duration, count, and one-shot versus persistent mode.
- Status signals may expose injection_active, unauthorized_request, and target_invalid conditions.

## Parameters and Configuration Knobs

- Number of injection targets and target ID width.
- Supported fault classes and timing modes.
- Lifecycle or privilege gating.
- Pulse, hold, or pattern-based injection support.

## Internal Architecture and Dataflow

The injector generally contains target decode, timing and duration control, gating by lifecycle or debug enable, and status reporting. The architectural contract should define whether injection happens by overriding live signals, perturbing data, or requesting behavior from the target block, because those mechanisms carry very different risk and fidelity.

## Clocking, Reset, and Timing Assumptions

The block assumes injection is allowed only in authorized modes and that targets are designed to tolerate or at least meaningfully react to injected faults. Reset should clear active injections immediately unless a safety analysis explicitly requires persistence. If field use is supported, that scope must be documented far more tightly than ordinary lab-debug use.

## Latency, Throughput, and Resource Considerations

Performance is not about throughput; it is about precise and reproducible perturbation timing. Area is modest. The main design tradeoff is between flexible injection capability and minimizing the attack or accidental-misuse surface in production systems.

## Verification Strategy

- Verify each fault class triggers the intended target behavior and no unintended targets.
- Check authorization and lifecycle gating to ensure production misuse is blocked.
- Stress timing, pulse width, and repeated injection scenarios.
- Validate safe clearing of injected faults on reset or disable.

## Integration Notes and Dependencies

Fault Injector commonly targets Assertion Monitors, ECC paths, Safe State logic, and Event Recorder or Error Logger validation flows. It should be tightly tied to debug or validation policy and never treated as an always-safe operational feature.

## Edge Cases, Failure Modes, and Design Risks

- An injector that survives into production without strict gating can become a severe security and reliability hazard.
- Injection mechanisms that bypass the intended failure mode can produce misleading validation coverage.
- Poor documentation of injection semantics can make test results nonreproducible across teams.

## Related Modules In This Domain

- assertion_monitor
- event_recorder
- error_logger
- safe_state_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Fault Injector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
