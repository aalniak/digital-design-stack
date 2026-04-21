# Module Family Verification Plan Template

## Verification Scope

- Family name:
- Stable core under test:
- Public wrappers in scope:
- Toolchain baseline:

## Verification Intent

State what must be proven about the family and what risks are highest.

## Configuration Sweep Matrix

Create a table with:

| Case id | Profile | Key parameters | Why this case matters | Expected flow |
| --- | --- | --- | --- | --- |

Expected flow examples:

- compile only
- smoke simulation
- randomized simulation
- formal proof

## Directed Simulation

List the basic tests every supported profile should pass.

## Randomized Simulation

List the stress scenarios, including stalls, bursts, resets, boundary behavior, and profile-specific traffic patterns.

## Assertions And Scoreboarding

List the invariants, reference models, and interface checks that should exist in simulation.

## Formal Verification

List the properties that belong on the stable core and any wrapper-specific assumptions or assertions.

## Illegal-Configuration Checks

Describe how the family should reject unsupported parameter combinations and how that rejection will be tested.

## Coverage Goals

Document which axes matter:

- interface profile coverage
- width or depth coverage
- latency-mode coverage
- watermark or status option coverage
- error-path coverage

## Pass Criteria

Define what must be true before the family can be called:

- bronze
- silver
- gold
- production

## Planned Testbench Layout

Document the intended contents of:

- `tb/sim/`
- `tb/formal/`
- `tb/vectors/`
