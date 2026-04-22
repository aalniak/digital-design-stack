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
23. `clock_fail_detector`
   - verification: simulation, synthesis sanity, formal
24. `clock_gating_wrapper`
   - verification: simulation, synthesis sanity, formal
25. `clock_mux_controller`
   - verification: simulation, synthesis sanity, formal
26. `frequency_meter`
   - verification: simulation, synthesis sanity, formal
27. `glitchless_clock_switch`
   - verification: simulation, synthesis sanity, formal
28. `pll_lock_monitor`
   - verification: simulation, synthesis sanity, formal
29. `pps_capture`
   - verification: simulation, synthesis sanity, formal
30. `reset_sequencer`
   - verification: simulation, synthesis sanity, formal
31. `power_domain_controller`
   - verification: simulation, synthesis sanity, formal
32. `wakeup_controller`
   - verification: simulation, synthesis sanity, formal
33. `retention_controller`
   - verification: simulation, synthesis sanity, formal
34. `timestamp_counter`
   - verification: simulation, synthesis sanity, formal
35. `rtc_block`
   - verification: simulation, synthesis sanity, formal
36. `adder_subtractor`
   - verification: simulation, synthesis sanity, formal
37. `saturating_adder`
   - verification: simulation, synthesis sanity, formal
38. `comparator_tree`
   - verification: simulation, synthesis sanity, formal
39. `abs_min_max`
   - verification: simulation, synthesis sanity, formal
40. `barrel_shifter`
   - verification: simulation, synthesis sanity, formal
41. `leading_zero_counter`
   - verification: simulation, synthesis sanity, formal
42. `popcount_unit`
   - verification: simulation, synthesis sanity, formal
43. `multiplier`
   - verification: simulation, synthesis sanity, formal
44. `complex_multiplier`
   - verification: simulation, synthesis sanity, formal
45. `divider`
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

1. `reciprocal_approximation`
2. `fixed_to_float_converter`
3. `square_root`

## Current Guidance

- Keep the cores small and strongly parameterized.
- Prefer wrapper-based interface variation over giant optional-port modules.
- Treat simulation and formal as part of implementation completion, not follow-up work.
