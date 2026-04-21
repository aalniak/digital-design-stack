# Foundational Implementation Progress

## Verified Implementations

The following foundational modules currently have implemented RTL, executable verification flows, and checked output artifacts:

1. `async_fifo`
   - family wrappers: native, stream, packet
   - verification: simulation, synthesis sanity, formal
2. `pulse_synchronizer`
   - verification: simulation, synthesis sanity, formal
3. `bus_synchronizer`
   - verification: simulation, synthesis sanity, formal
4. `reset_synchronizer`
   - verification: simulation, synthesis sanity, formal

## Current Pattern That Is Working

Each implemented module now has:

- a configuration contract in `spec/`
- a verification plan in `tb/`
- synthesizable RTL in `rtl/`
- a self-checking simulation in `tb/sim/`
- a lightweight formal harness in `tb/formal/`
- a dedicated verification runner in `scripts/`
- a per-module implementation status note in `spec/IMPLEMENTATION_STATUS.md`

## Immediate Next Candidates

The next strongest low-risk foundational modules are:

1. `event_counter`
2. `free_running_counter`
3. `register_slice`
4. `skid_buffer`

## Current Guidance

- Keep the cores small and strongly parameterized.
- Prefer wrapper-based interface variation over giant optional-port modules.
- Treat simulation and formal as part of implementation completion, not follow-up work.
