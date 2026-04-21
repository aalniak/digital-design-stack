# Module Documentation Task List

This checklist tracks the creation of a deep, domain-specific `MODULE.md` file for every module folder under `domains/`.

## Documentation Rules

- Create `MODULE.md` inside each module folder.
- Write each module document one by one; do not batch shallow placeholder text.
- Keep documentation domain-specific even when module names repeat across domains.
- Prefer depth over speed: explain purpose, interfaces, parameters, architecture, timing assumptions, verification ideas, integration notes, and edge cases.
- Mark a task complete only when the module folder contains a substantive `MODULE.md` rather than a stub.

## Suggested Structure For Each `MODULE.md`

1. Overview
2. Domain Context
3. Problem Solved
4. Typical Use Cases
5. Interfaces and Signal-Level Behavior
6. Parameters and Configuration Knobs
7. Internal Architecture and Dataflow
8. Clocking, Reset, CDC, and Timing Assumptions
9. Latency, Throughput, and Resource Considerations
10. Verification Strategy
11. Integration Notes and Dependencies
12. Edge Cases, Failure Modes, and Design Risks
13. Related Modules In This Domain

## Progress Summary

- Domains: 32
- Module folders: 553
- Modules documented: 553 / 553

## Task Checklist

### Core RTL Infrastructure and Glue

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/core_rtl_infrastructure_and_glue/`.
- Modules in this domain: 20

- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/async_fifo/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/bus_synchronizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/depacketizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/event_counter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/free_running_counter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/gearbox/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/interrupt_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/packet_fifo/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/packetizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/priority_arbiter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/pulse_synchronizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/register_slice/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/reset_synchronizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/round_robin_arbiter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/skid_buffer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/stream_demux/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/stream_fifo/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/stream_mux/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/timer_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/core_rtl_infrastructure_and_glue/width_converter/MODULE.md`.

### Clocking, Reset, Power, and Timing

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/clocking_reset_power_and_timing/`.
- Modules in this domain: 15

- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/clock_divider/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/clock_enable_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/clock_fail_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/clock_gating_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/clock_mux_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/frequency_meter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/glitchless_clock_switch/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/pll_lock_monitor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/power_domain_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/pps_capture/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/reset_sequencer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/retention_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/rtc_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/timestamp_counter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/clocking_reset_power_and_timing/wakeup_controller/MODULE.md`.

### Arithmetic and Numeric Computing

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/arithmetic_and_numeric_computing/`.
- Modules in this domain: 18

- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/abs_min_max/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/adder_subtractor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/barrel_shifter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/bfloat16_mac/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/comparator_tree/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/complex_multiplier/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/cordic_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/divider/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/fixed_to_float_converter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/float_to_fixed_converter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/fp16_mac/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/leading_zero_counter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/mac_unit/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/multiplier/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/popcount_unit/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/reciprocal_approximation/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/saturating_adder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/arithmetic_and_numeric_computing/square_root/MODULE.md`.

### Buffering, Memory, and Data Movement

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/buffering_memory_and_data_movement/`.
- Modules in this domain: 16

- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/bank_interleaver/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/burst_adapter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/cache_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/circular_buffer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/descriptor_fetcher/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/dma_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/dp_ram_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/ecc_memory_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/frame_buffer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/line_buffer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/memory_scrubber/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/ping_pong_buffer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/rom_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/scatter_gather_dma/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/scratchpad_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/buffering_memory_and_data_movement/sp_ram_wrapper/MODULE.md`.

### SoC Interconnect and Control Plane

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/soc_interconnect_and_control_plane/`.
- Modules in this domain: 16

- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/address_decoder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/apb_bridge/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/axi_lite_slave/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/axi_stream_adapter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/axi4_master/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/burst_merger/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/burst_splitter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/bus_crossbar/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/csr_bank/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/debug_bridge/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/interrupt_aggregator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/mailbox_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/semaphore_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/tilelink_adapter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/transaction_tracker/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/soc_interconnect_and_control_plane/wishbone_bridge/MODULE.md`.

### Low-Speed Peripheral Interfaces

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/low_speed_peripheral_interfaces/`.
- Modules in this domain: 21

- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/can_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/can_fd_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/emmc_lite_host/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/gpio_bank/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/i2c_master_slave/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/i2s_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/i3c_basic_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/lin_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/mdio_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/one_wire_master/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/pdm_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/pulse_capture/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/pwm_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/qspi_flash_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/quadrature_decoder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/sdio_host/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/spdif_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/spi_master_slave/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/tdm_audio_port/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/uart_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/low_speed_peripheral_interfaces/usb_fs_device_core/MODULE.md`.

### High-Speed Serial, Networking, and Packet Processing

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/high_speed_serial_networking_and_packet_processing/`.
- Modules in this domain: 21

- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/arp_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/aurora_style_link/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/checksum_offload/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/crc_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/descrambler/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/elastic_buffer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/encoder_64b66b/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/encoder_8b10b/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/ethernet_mac/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/ipv4_router_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/ipv6_parser/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/packet_parser/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/pcie_dma_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/pcie_endpoint_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/pcs_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/ptp_timestamp_unit/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/scrambler/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/tcp_offload_lite/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/tsn_shaper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/udp_stack/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/high_speed_serial_networking_and_packet_processing/vlan_tagger/MODULE.md`.

### Storage and External Memory Systems

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/storage_and_external_memory_systems/`.
- Modules in this domain: 16

- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/ahci_lite_frontend/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/bad_block_manager/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/ddr_ecc_frontend/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/ddr_scheduler_frontend/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/emmc_host_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/flash_ecc_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/nand_flash_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/nvme_completion_queue/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/nvme_submission_queue/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/read_prefetch_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/reorder_buffer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/sata_link_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/sd_host_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/spi_flash_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/storage_dma_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/storage_and_external_memory_systems/writeback_cache/MODULE.md`.

### DSP and Sampled-Data Processing

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/dsp_and_sampled_data_processing/`.
- Modules in this domain: 25

- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/agc_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/beamformer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/biquad_iir/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/channelizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/cic_decimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/cic_interpolator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/correlator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/dc_blocker/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/dct_idct_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/ddc_chain/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/digital_mixer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/duc_chain/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/fft_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/fir_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/halfband_fir_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/hilbert_transform/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/ifft_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/lms_adaptive_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/matched_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/moving_average_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/notch_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/numerically_controlled_oscillator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/polyphase_resampler/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/symmetric_fir_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/dsp_and_sampled_data_processing/window_generator/MODULE.md`.

### Control, Estimation, and Feedback Systems

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/control_estimation_and_feedback_systems/`.
- Modules in this domain: 15

- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/anti_windup_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/deadband_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/digital_dll/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/digital_pll/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/frequency_locked_loop/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/jerk_limited_profile/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/kalman_filter_core/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/lead_lag_compensator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/limiter_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/lookup_calibration_unit/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/pi_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/pid_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/setpoint_ramp/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/state_observer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/control_estimation_and_feedback_systems/trajectory_generator/MODULE.md`.

### Sensor Acquisition and Instrumentation

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/sensor_acquisition_and_instrumentation/`.
- Modules in this domain: 14

- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/adc_capture_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/calibration_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/dac_playback_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/digital_lockin_amplifier/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/event_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/frequency_counter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/histogram_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/pulse_counter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/sample_packer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/sensor_hub_mux/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/threshold_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/time_to_digital_capture/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/timestamp_aligner/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sensor_acquisition_and_instrumentation/trigger_sequencer/MODULE.md`.

### Image Processing

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/image_processing/`.
- Modules in this domain: 28

- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/adaptive_thresholding/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/ae_awb_af_statistics/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/affine_warp/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/bad_pixel_correction/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/bayer_unpacker/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/bilateral_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/black_level_correction/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/canny_edge/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/clahe_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/color_correction_matrix/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/color_space_converter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/crop_resize_rotate/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/demosaic_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/gamma_lut/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/gaussian_blur/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/histogram_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/integral_image/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/laplacian_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/lens_shading_correction/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/median_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/morphology_dilate/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/morphology_erode/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/raw_pixel_unpacker/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/remap_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/sharpening_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/sobel_edge/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/thresholding_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/image_processing/white_balance/MODULE.md`.

### Video Processing and Display Pipelines

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/video_processing_and_display_pipelines/`.
- Modules in this domain: 22

- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/alpha_blender/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/chroma_resampler/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/compositor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/csi2_rx_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/deinterlacer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/displayport_tx_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/dsi_tx_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/frame_buffer_reader/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/frame_buffer_writer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/frame_rate_converter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/hdmi_rx_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/hdmi_tx_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/hdr_tone_mapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/osd_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/panel_timing_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/sdi_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/sync_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/sync_separator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/test_pattern_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/video_mixer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/video_scaler/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/video_processing_and_display_pipelines/video_timing_controller/MODULE.md`.

### Audio, Speech, and Acoustic Processing

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/audio_speech_and_acoustic_processing/`.
- Modules in this domain: 22

- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/acoustic_echo_canceller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/acoustic_localizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/audio_agc/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/audio_fifo/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/audio_mixer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/binaural_renderer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/compressor_limiter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/crossover_filter_bank/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/equalizer_biquad_bank/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/gain_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/i2s_rx_tx/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/mel_filter_bank/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/mfcc_extractor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/microphone_beamformer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/noise_gate/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/pdm_decimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/pitch_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/sample_rate_converter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/spdif_rx_tx/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/spectrogram_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/tdm_audio_rx_tx/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/audio_speech_and_acoustic_processing/voice_activity_detector/MODULE.md`.

### Computer Vision and Perception

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/computer_vision_and_perception/`.
- Modules in this domain: 18

- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/background_subtractor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/blob_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/bounding_box_decoder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/connected_components_labeler/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/corner_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/descriptor_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/descriptor_matcher/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/disparity_refiner/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/feature_extractor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/hough_transform/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/kalman_tracker/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/multi_object_association/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/non_maximum_suppression/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/occupancy_grid_builder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/optical_flow_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/perspective_transform/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/segmentation_postprocessor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/computer_vision_and_perception/stereo_matcher/MODULE.md`.

### Wireless, SDR, and Baseband

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/wireless_sdr_and_baseband/`.
- Modules in this domain: 24

- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/bch_codec/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/carrier_recovery/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/cfo_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/channel_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/convolutional_encoder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/correlator_bank/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/cyclic_prefix_handler/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/deinterleaver/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/descrambler/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/equalizer_core/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/framer_deframer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/harq_buffer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/interleaver/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/ldpc_codec/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/mimo_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/ofdm_modem_core/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/pilot_inserter_extractor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/polar_codec/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/prbs_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/qam_mapper_demapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/reed_solomon_codec/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/scrambler/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/timing_synchronizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/wireless_sdr_and_baseband/viterbi_decoder/MODULE.md`.

### Radar Processing

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/radar_processing/`.
- Modules in this domain: 18

- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/angle_fft/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/array_calibration/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/cfar_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/chirp_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/clutter_suppressor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/dechirp_mixer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/digital_beamformer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/doa_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/doppler_fft/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/iq_imbalance_corrector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/micro_doppler_analyzer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/mti_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/pulse_compression/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/range_doppler_builder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/range_fft/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/sar_backprojection_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/stap_research_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/radar_processing/target_tracker/MODULE.md`.

### Sonar and Array Acoustics

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/sonar_and_array_acoustics/`.
- Modules in this domain: 14

- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/array_calibration/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/bearing_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/click_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/delay_and_sum_beamformer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/doppler_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/hydrophone_frontend_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/matched_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/passive_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/passive_spectrogram/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/ping_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/reverberation_suppressor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/sonar_data_framer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/target_tracker/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/sonar_and_array_acoustics/tdoa_estimator/MODULE.md`.

### LiDAR, ToF, and 3D Sensing

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/lidar_tof_and_3d_sensing/`.
- Modules in this domain: 12

- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/laser_trigger_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/multi_return_resolver/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/peak_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/point_cloud_packer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/range_calibration_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/reflectivity_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/scan_pattern_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/tdc_capture/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/timestamp_synchronizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/tof_histogrammer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/voxel_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/lidar_tof_and_3d_sensing/walk_error_corrector/MODULE.md`.

### GNSS, Navigation, and Sensor Fusion

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/gnss_navigation_and_sensor_fusion/`.
- Modules in this domain: 15

- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/acquisition_correlator_bank/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/carrier_phase_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/carrier_tracking_pll/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/code_tracking_dll/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/dead_reckoning_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/disciplined_clock_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/ephemeris_decoder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/frequency_locked_loop/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/imu_preintegration/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/kalman_fusion_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/nav_bit_synchronizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/pps_aligner/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/prn_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/pseudorange_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/gnss_navigation_and_sensor_fusion/strapdown_integrator/MODULE.md`.

### Motor Control and Digital Power

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/motor_control_and_digital_power/`.
- Modules in this domain: 18

- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/center_aligned_pwm/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/clarke_transform/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/current_reconstruction/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/dead_time_inserter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/flux_observer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/foc_current_loop/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/hall_sensor_decoder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/inverse_park_transform/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/overcurrent_shutdown/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/park_transform/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/pfc_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/quadrature_encoder_decoder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/resolver_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/smps_digital_compensator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/soft_start_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/space_vector_pwm/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/speed_loop_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/motor_control_and_digital_power/speed_observer/MODULE.md`.

### Robotics, Industrial Automation, and Fieldbuses

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/robotics_industrial_automation_and_fieldbuses/`.
- Modules in this domain: 14

- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/canopen_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/emergency_stop_latch/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/ethercat_slave_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/kinematics_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/machine_state_sequencer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/modbus_rtu_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/modbus_tcp_bridge/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/motion_profile_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/profinet_endpoint/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/safe_io_voter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/safety_interlock_logic/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/servo_loop_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/stepper_pulse_generator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/robotics_industrial_automation_and_fieldbuses/timestamp_synchronizer/MODULE.md`.

### Security and Cryptography

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/security_and_cryptography/`.
- Modules in this domain: 19

- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/aes_core/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/aes_gcm_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/anti_rollback_counter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/chacha20_core/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/cmac_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/constant_time_compare/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/drbg_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/ecc_p256_scalar_mult/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/hmac_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/key_ladder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/otp_efuse_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/poly1305_core/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/puf_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/rsa_modexp/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/secure_boot_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/sha2_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/sha3_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/tamper_monitor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/security_and_cryptography/trng_block/MODULE.md`.

### Compression, Coding, and ECC/FEC

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/compression_coding_and_ecc_fec/`.
- Modules in this domain: 18

- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/arithmetic_coder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/bch_codec/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/crc_family/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/deflate_building_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/deinterleaver/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/delta_encoder_decoder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/entropy_adapter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/golomb_rice_codec/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/hamming_secded/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/huffman_codec/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/interleaver/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/jpeg_dct_quantizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/jpeg_huffman_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/lz4_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/packet_deframer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/packet_framer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/reed_solomon_codec/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/compression_coding_and_ecc_fec/run_length_codec/MODULE.md`.

### AI/ML Acceleration

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/ai_ml_acceleration/`.
- Modules in this domain: 18

- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/activation_unit/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/argmax_topk/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/attention_score_unit/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/batchnorm_layernorm/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/conv2d_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/depthwise_conv_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/detector_postprocessor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/embedding_lookup/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/gemm_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/nms_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/pointwise_conv_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/pooling_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/qkv_projection_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/quantize_dequantize/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/softmax_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/sparse_decode_unit/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/systolic_array/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/ai_ml_acceleration/tensor_dma/MODULE.md`.

### Biomedical and Ultrasound

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/biomedical_and_ultrasound/`.
- Modules in this domain: 12

- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/bioimpedance_demodulator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/doppler_flow_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/ecg_bandpass_filter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/eeg_filter_bank/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/heart_rate_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/medical_data_framer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/motion_artifact_rejector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/patient_alarm_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/pulse_oximetry_demodulator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/qrs_detector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/respiration_rate_estimator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/biomedical_and_ultrasound/ultrasound_beamformer/MODULE.md`.

### Scientific Computing and Specialty Sensing

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/scientific_computing_and_specialty_sensing/`.
- Modules in this domain: 14

- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/cholesky_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/compressive_sensing_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/correlation_matrix_builder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/finite_difference_stencil/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/fringe_phase_unwrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/high_speed_histogrammer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/hyperspectral_cube_unpacker/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/interferometry_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/lu_decomposition_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/matrix_multiply_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/monte_carlo_rng/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/particle_filter_core/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/qr_decomposition_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/scientific_computing_and_specialty_sensing/spectral_calibration_engine/MODULE.md`.

### Debug, Test, DFT, Safety, and Reliability

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/debug_test_dft_safety_and_reliability/`.
- Modules in this domain: 18

- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/assertion_monitor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/boundary_scan_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/brownout_fault_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/bus_monitor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/ecc_scrubber/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/error_logger/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/event_recorder/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/fault_injector/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/jtag_tap/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/lbist_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/lockstep_comparator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/mbist_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/memory_march_tester/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/prbs_generator_checker/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/safe_state_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/scan_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/tmr_voter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/debug_test_dft_safety_and_reliability/trace_funnel/MODULE.md`.

### Processor Subsystems and Accelerator Integration

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/processor_subsystems_and_accelerator_integration/`.
- Modules in this domain: 14

- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/accelerator_dispatcher/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/atomic_semaphore_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/boot_rom/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/clint_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/coprocessor_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/data_cache/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/debug_module/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/instruction_cache/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/mmu_lite/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/multicore_mailbox/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/performance_counter_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/plic_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/riscv_core_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/processor_subsystems_and_accelerator_integration/scratchpad_tcm/MODULE.md`.

### FPGA Platform Support and Reconfiguration

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/fpga_platform_support_and_reconfiguration/`.
- Modules in this domain: 12

- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/bitstream_loader/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/ddr_phy_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/icap_pcap_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/iodelay_controller/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/mmcm_pll_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/partial_reconfiguration_manager/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/serdes_calibration_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/startup_sequencer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/transceiver_loopback_tester/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/transceiver_reset_fsm/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/vendor_dsp_wrapper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/fpga_platform_support_and_reconfiguration/vendor_ram_wrapper/MODULE.md`.

### Aerospace, Space, and Harsh-Environment Systems

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/aerospace_space_and_harsh_environment_systems/`.
- Modules in this domain: 12

- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/arinc429_helper/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/ccsds_deframer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/ccsds_framer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/fault_management_unit/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/health_monitor_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/mil_std_1553_interface/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/radiation_memory_scrubber/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/redundant_voter_fabric/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/spacewire_link_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/telecommand_packetizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/telemetry_packetizer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/aerospace_space_and_harsh_environment_systems/time_triggered_scheduler/MODULE.md`.

### Graphics, HMI, and Display Composition

- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/graphics_hmi_and_display_composition/`.
- Modules in this domain: 14

- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/blitter/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/cursor_overlay/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/dithering_block/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/font_rom_renderer/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/frame_compositor/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/icon_cache/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/line_draw_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/palette_lookup/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/rectangle_fill_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/simple_2d_accelerator/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/sprite_engine/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/text_overlay/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/touch_bridge/MODULE.md`.
- [x] Write deep, domain-specific `MODULE.md` for `domains/graphics_hmi_and_display_composition/ui_layer_mixer/MODULE.md`.

