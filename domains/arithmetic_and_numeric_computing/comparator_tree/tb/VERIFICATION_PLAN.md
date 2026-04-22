# Comparator Tree Verification Plan

## Verification Goals

- Check deterministic max or min selection under the configured numeric interpretation.
- Check deterministic tie-breaking under equal winning values.
- Check that masked-off candidates do not influence the result.
- Check all-invalid output behavior.
- Check index and value alignment.

## Simulation Coverage

The first-pass simulation covers:

- signed max reduction with distinct values
- tie-breaking toward the lowest index
- masking away higher-valued candidates
- all-invalid idle behavior
- unsigned min reduction
- index suppression behavior

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small signed max instance:

- winner value matches a software-style masked reduction
- winner index matches the same reduction
- `any_valid` matches whether at least one candidate is enabled
