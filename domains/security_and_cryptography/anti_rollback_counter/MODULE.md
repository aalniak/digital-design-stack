# Anti-Rollback Counter

## Overview

Anti-Rollback Counter stores and enforces a monotonic security version or epoch used to reject downgraded firmware or configuration images. It provides the stateful policy mechanism that turns secure signature verification into secure forward-only update behavior.

## Domain Context

Anti-rollback protection is a lifecycle control element in secure systems that prevents old but validly signed firmware from being reinstalled after a vulnerability has been fixed. In this domain the counter is not just a register; it is a security state anchor that interacts with boot policy, update tooling, and nonvolatile storage trust assumptions.

## Problem Solved

Signature verification alone cannot prevent attackers from replaying an older signed image that still contains known flaws. A dedicated monotonic counter creates an independently anchored security version check so old images can be refused even when their signatures remain valid.

## Typical Use Cases

- Blocking installation of older signed firmware during secure update.
- Maintaining lifecycle security version across reboot and power loss.
- Providing version gating for boot ROM, second-stage bootloader, and field-update agents.
- Supporting controlled manufacturing exceptions where rollback is allowed only in tightly scoped lifecycle modes.

## Interfaces and Signal-Level Behavior

- Inputs usually include candidate image security version, increment request, lifecycle mode, and authenticated authorization or policy context.
- Outputs provide version_accept, version_reject, current_counter_value, and increment-complete status.
- Control interfaces may configure which lifecycle states permit advancement and whether test or recovery modes are exempt.
- Status outputs often expose storage_fault, monotonicity_error, and invalid-lifecycle access attempts.

## Parameters and Configuration Knobs

- Counter width and maximum supported security version.
- Back-end storage target such as OTP, eFuse, monotonic NVM cell, or secure flash mirror.
- Policy options for boot-time compare-only versus boot plus update-time advance.
- Whether multiple independent rollback domains are supported for separate firmware components.

## Internal Architecture and Dataflow

Typical designs combine trusted nonvolatile state, compare logic, authorized-increment control, and lifecycle gating. The important architectural distinction is whether the block updates the monotonic state directly or only arbitrates a lower storage primitive, because that determines how atomicity, power-loss tolerance, and fault reporting must be handled.

## Clocking, Reset, and Timing Assumptions

The counter assumes its backing storage cannot be trivially rewritten by untrusted software or debug access. Reset should not alter the stored security version and must report storage-read failure unambiguously. If increment authorization depends on image authentication occurring elsewhere, that trust boundary should be explicit so no one assumes the counter validates signatures by itself.

## Latency, Throughput, and Resource Considerations

This block is control-plane heavy rather than throughput heavy. Latency is dominated by secure storage read and update timing, especially for eFuse- or OTP-backed implementations. The relevant performance metric is reliable monotonic behavior across brownouts and interrupted updates, not high transaction rate.

## Verification Strategy

- Verify accept and reject behavior across equal, lower, and higher candidate versions.
- Stress interrupted increment or power-loss scenarios to confirm the stored version never decreases or enters an ambiguous state.
- Check lifecycle-mode restrictions so manufacturing or recovery exceptions cannot leak into production policy.
- Validate handling of storage faults and compare failures so boot policy fails safely.

## Integration Notes and Dependencies

Anti-Rollback Counter is consumed by Secure Boot Block and firmware-update state machines and should share policy vocabulary with image metadata tooling. It often works with OTP or eFuse controllers and must align with lifecycle states so development flexibility does not persist into fielded product behavior.

## Edge Cases, Failure Modes, and Design Risks

- If increment and image-accept ordering are wrong, a failed update may brick the device or leave rollback still possible.
- Weak separation between production and recovery lifecycle modes can silently reintroduce rollback paths.
- A monotonic counter without clear atomicity guarantees may fail precisely when power is least stable, such as during update.

## Related Modules In This Domain

- secure_boot_block
- otp_efuse_controller
- tamper_monitor
- key_ladder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Anti-Rollback Counter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
