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
5. `event_counter`
   - verification: simulation, synthesis sanity, formal
6. `free_running_counter`
   - verification: simulation, synthesis sanity, formal
7. `register_slice`
   - verification: simulation, synthesis sanity, formal
8. `skid_buffer`
   - verification: simulation, synthesis sanity, formal
9. `timer_block`
   - verification: simulation, synthesis sanity, formal
10. `interrupt_controller`
   - verification: simulation, synthesis sanity, formal
11. `priority_arbiter`
   - verification: simulation, synthesis sanity, formal
12. `round_robin_arbiter`
   - verification: simulation, synthesis sanity, formal
13. `stream_fifo`
   - verification: simulation, synthesis sanity, formal
14. `packet_fifo`
   - verification: simulation, synthesis sanity, formal
15. `stream_demux`
   - verification: simulation, synthesis sanity, formal
16. `width_converter`
   - verification: simulation, synthesis sanity, formal
17. `stream_mux`
    - verification: simulation, synthesis sanity, formal
18. `gearbox`
   - verification: simulation, synthesis sanity, formal
19. `packetizer`
   - verification: simulation, synthesis sanity, formal
20. `depacketizer`
   - verification: simulation, synthesis sanity, formal
21. `clock_divider`
   - verification: simulation, synthesis sanity, formal
22. `clock_enable_generator`
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

1. `clock_fail_detector`
2. `clock_gating_wrapper`
3. `clock_mux_controller`

## Current Guidance

- Keep the cores small and strongly parameterized.
- Prefer wrapper-based interface variation over giant optional-port modules.
- Treat simulation and formal as part of implementation completion, not follow-up work.
