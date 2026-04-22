# Clock Gating Wrapper Configuration Contract

## Implemented Configuration Surface

The current `clock_gating_wrapper` baseline provides a portable clock-gating policy wrapper with the following parameter set:

- `DEFAULT_ENABLE`
  - startup gate-open policy after reset releases
  - legal values: `0` or `1`
- `ACTIVE_HIGH_ENABLE`
  - selects whether `enable_req = 1` means open gate or closed gate
  - legal values: `0` or `1`
- `TEST_BYPASS_EN`
  - enables `test_bypass` override support
  - legal values: `0` or `1`
- `BYPASS_EN`
  - enables normal functional bypass support
  - legal values: `0` or `1`
- `FPGA_SAFE_MODE`
  - `1` keeps `gated_clk` free-running and exports the policy through `domain_ce`
  - `0` produces a physically gated clock output in RTL form
  - legal values: `0` or `1`
- `ENABLE_SYNC_STAGES`
  - number of source-clock synchronizer stages applied to `enable_req`
  - legal range: `ENABLE_SYNC_STAGES >= 0`

## Ports

- `clk_in`
  - source clock to be gated or policy-wrapped
- `rst_n`
  - active-low reset
- `enable_req`
  - gate-open request input before polarity normalization and optional synchronization
- `test_bypass`
  - scan or debug override request when `TEST_BYPASS_EN = 1`
- `bypass`
  - functional bypass request when `BYPASS_EN = 1`
- `gated_clk`
  - gated clock output in ASIC-style mode or free-running source clock in FPGA-safe mode
- `domain_ce`
  - accepted gate-open policy output for downstream clock-enable style use
- `gate_open`
  - accepted gate state after low-phase latching
- `override_active`
  - reset-quiet indication that test bypass or functional bypass is being asked for

## Behavioral Contract

- `enable_req` is normalized according to `ACTIVE_HIGH_ENABLE`.
- If `ENABLE_SYNC_STAGES > 0`, the normalized request is synchronized in the `clk_in` domain before it reaches the gate latch.
- The effective gate-open request is the OR of the synchronized enable request, `test_bypass`, and `bypass`.
- The accepted gate state updates only on the low phase of `clk_in` by latching the effective request on `negedge clk_in`.
- In `FPGA_SAFE_MODE = 0`, `gated_clk` only toggles while `gate_open = 1`.
- In `FPGA_SAFE_MODE = 1`, `gated_clk` is always `clk_in`, and downstream logic is expected to honor `domain_ce` instead of depending on a physically stopped clock.

## Current Implementation Notes

- This baseline is a policy wrapper, not a technology-mapping layer to a foundry ICG primitive.
- `test_bypass` and `bypass` are sampled directly into the low-phase gate latch. They should only change in a source-clock-safe control domain or under documented integration constraints.
- `override_active` reflects request intent, while `gate_open` reflects the accepted low-phase-latched gate state.
- `override_active` is intentionally suppressed during reset so the public status interface stays quiet until the wrapper is live.
- The default startup state is controlled by `DEFAULT_ENABLE` and propagates both to `gate_open` and to the reset state of the optional enable synchronizer.

## Illegal Configurations

- `DEFAULT_ENABLE` not in `{0, 1}`
- `ACTIVE_HIGH_ENABLE` not in `{0, 1}`
- `TEST_BYPASS_EN` not in `{0, 1}`
- `BYPASS_EN` not in `{0, 1}`
- `FPGA_SAFE_MODE` not in `{0, 1}`
- `ENABLE_SYNC_STAGES < 0`

## Planned Future Expansion

- technology-cell wrapper mode for ASIC-specific ICG mapping
- explicit gate-acknowledge or state-transition observability
- optional separate synchronization for bypass controls
- stronger wrapper families for tick-only or CE-only downstream integration
