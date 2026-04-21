$workspaceRoot = Split-Path -Parent $PSScriptRoot
$domainsRoot = Join-Path $workspaceRoot 'domains'

$domains = @(
    [ordered]@{
        Name = 'core_rtl_infrastructure_and_glue'
        Title = 'Core RTL Infrastructure and Glue'
        Description = 'Foundational reusable logic for safe composition, flow control, arbitration, and generic control/data plumbing.'
        Modules = @(
            'reset_synchronizer',
            'pulse_synchronizer',
            'bus_synchronizer',
            'async_fifo',
            'skid_buffer',
            'register_slice',
            'stream_fifo',
            'packet_fifo',
            'round_robin_arbiter',
            'priority_arbiter',
            'stream_mux',
            'stream_demux',
            'packetizer',
            'depacketizer',
            'width_converter',
            'gearbox',
            'timer_block',
            'free_running_counter',
            'event_counter',
            'interrupt_controller'
        )
    },
    [ordered]@{
        Name = 'clocking_reset_power_and_timing'
        Title = 'Clocking, Reset, Power, and Timing'
        Description = 'Support IP for deterministic startup, clock management, timing references, and low-power system behavior.'
        Modules = @(
            'reset_sequencer',
            'clock_divider',
            'clock_enable_generator',
            'clock_mux_controller',
            'clock_gating_wrapper',
            'pll_lock_monitor',
            'frequency_meter',
            'timestamp_counter',
            'pps_capture',
            'rtc_block',
            'wakeup_controller',
            'power_domain_controller',
            'retention_controller',
            'clock_fail_detector',
            'glitchless_clock_switch'
        )
    },
    [ordered]@{
        Name = 'arithmetic_and_numeric_computing'
        Title = 'Arithmetic and Numeric Computing'
        Description = 'Reusable arithmetic, fixed-point, floating-point, and transcendental building blocks for compute-heavy designs.'
        Modules = @(
            'adder_subtractor',
            'saturating_adder',
            'comparator_tree',
            'abs_min_max',
            'leading_zero_counter',
            'popcount_unit',
            'barrel_shifter',
            'multiplier',
            'mac_unit',
            'divider',
            'reciprocal_approximation',
            'square_root',
            'cordic_engine',
            'complex_multiplier',
            'fixed_to_float_converter',
            'float_to_fixed_converter',
            'fp16_mac',
            'bfloat16_mac'
        )
    },
    [ordered]@{
        Name = 'buffering_memory_and_data_movement'
        Title = 'Buffering, Memory, and Data Movement'
        Description = 'Memory wrappers and movement engines for staged processing, high-throughput buffering, and predictable latency.'
        Modules = @(
            'sp_ram_wrapper',
            'dp_ram_wrapper',
            'rom_wrapper',
            'circular_buffer',
            'ping_pong_buffer',
            'line_buffer',
            'frame_buffer',
            'bank_interleaver',
            'dma_engine',
            'scatter_gather_dma',
            'descriptor_fetcher',
            'burst_adapter',
            'ecc_memory_wrapper',
            'memory_scrubber',
            'cache_controller',
            'scratchpad_controller'
        )
    },
    [ordered]@{
        Name = 'soc_interconnect_and_control_plane'
        Title = 'SoC Interconnect and Control Plane'
        Description = 'Bus fabrics, register access, bridging, and control-plane connectivity for SoC assembly.'
        Modules = @(
            'axi_lite_slave',
            'axi4_master',
            'axi_stream_adapter',
            'apb_bridge',
            'wishbone_bridge',
            'tilelink_adapter',
            'address_decoder',
            'bus_crossbar',
            'transaction_tracker',
            'burst_splitter',
            'burst_merger',
            'csr_bank',
            'mailbox_block',
            'semaphore_block',
            'interrupt_aggregator',
            'debug_bridge'
        )
    },
    [ordered]@{
        Name = 'low_speed_peripheral_interfaces'
        Title = 'Low-Speed Peripheral Interfaces'
        Description = 'Classic board-level peripheral controllers and mixed-control interfaces used in embedded digital systems.'
        Modules = @(
            'uart_controller',
            'spi_master_slave',
            'qspi_flash_interface',
            'i2c_master_slave',
            'i3c_basic_controller',
            'mdio_controller',
            'gpio_bank',
            'one_wire_master',
            'pwm_generator',
            'pulse_capture',
            'quadrature_decoder',
            'sdio_host',
            'emmc_lite_host',
            'usb_fs_device_core',
            'can_controller',
            'can_fd_controller',
            'lin_controller',
            'i2s_interface',
            'tdm_audio_port',
            'spdif_interface',
            'pdm_interface'
        )
    },
    [ordered]@{
        Name = 'high_speed_serial_networking_and_packet_processing'
        Title = 'High-Speed Serial, Networking, and Packet Processing'
        Description = 'Packet-oriented datapath modules for wired communication, framing, timestamping, and fast serial transport.'
        Modules = @(
            'ethernet_mac',
            'pcs_wrapper',
            'crc_engine',
            'checksum_offload',
            'packet_parser',
            'vlan_tagger',
            'arp_engine',
            'ipv4_router_block',
            'ipv6_parser',
            'udp_stack',
            'tcp_offload_lite',
            'ptp_timestamp_unit',
            'tsn_shaper',
            'pcie_endpoint_wrapper',
            'pcie_dma_engine',
            'aurora_style_link',
            'encoder_8b10b',
            'encoder_64b66b',
            'scrambler',
            'descrambler',
            'elastic_buffer'
        )
    },
    [ordered]@{
        Name = 'storage_and_external_memory_systems'
        Title = 'Storage and External Memory Systems'
        Description = 'Controllers and front-end blocks for persistent storage, external memories, caching, and data staging.'
        Modules = @(
            'spi_flash_controller',
            'nand_flash_controller',
            'flash_ecc_block',
            'sd_host_controller',
            'emmc_host_controller',
            'ddr_scheduler_frontend',
            'ddr_ecc_frontend',
            'sata_link_block',
            'ahci_lite_frontend',
            'nvme_submission_queue',
            'nvme_completion_queue',
            'storage_dma_engine',
            'writeback_cache',
            'read_prefetch_engine',
            'reorder_buffer',
            'bad_block_manager'
        )
    },
    [ordered]@{
        Name = 'dsp_and_sampled_data_processing'
        Title = 'DSP and Sampled-Data Processing'
        Description = 'Core streaming signal-processing primitives for filtering, transforms, resampling, modulation, and detection.'
        Modules = @(
            'fir_filter',
            'symmetric_fir_filter',
            'halfband_fir_filter',
            'cic_decimator',
            'cic_interpolator',
            'polyphase_resampler',
            'biquad_iir',
            'moving_average_filter',
            'notch_filter',
            'fft_engine',
            'ifft_engine',
            'dct_idct_block',
            'hilbert_transform',
            'window_generator',
            'numerically_controlled_oscillator',
            'digital_mixer',
            'ddc_chain',
            'duc_chain',
            'agc_block',
            'dc_blocker',
            'matched_filter',
            'correlator',
            'lms_adaptive_filter',
            'channelizer',
            'beamformer'
        )
    },
    [ordered]@{
        Name = 'control_estimation_and_feedback_systems'
        Title = 'Control, Estimation, and Feedback Systems'
        Description = 'Digital control-loop and estimation blocks for closed-loop systems, tracking, and compensation.'
        Modules = @(
            'pi_controller',
            'pid_controller',
            'lead_lag_compensator',
            'digital_pll',
            'digital_dll',
            'frequency_locked_loop',
            'anti_windup_block',
            'state_observer',
            'kalman_filter_core',
            'trajectory_generator',
            'jerk_limited_profile',
            'lookup_calibration_unit',
            'limiter_block',
            'deadband_block',
            'setpoint_ramp'
        )
    },
    [ordered]@{
        Name = 'sensor_acquisition_and_instrumentation'
        Title = 'Sensor Acquisition and Instrumentation'
        Description = 'Digitization, timestamping, triggering, calibration, and measurement support for mixed-signal and sensing platforms.'
        Modules = @(
            'adc_capture_interface',
            'dac_playback_interface',
            'trigger_sequencer',
            'timestamp_aligner',
            'time_to_digital_capture',
            'frequency_counter',
            'pulse_counter',
            'histogram_engine',
            'sensor_hub_mux',
            'threshold_detector',
            'event_detector',
            'digital_lockin_amplifier',
            'sample_packer',
            'calibration_engine'
        )
    },
    [ordered]@{
        Name = 'image_processing'
        Title = 'Image Processing'
        Description = 'Per-frame and per-line image pipeline blocks for raw sensor cleanup, enhancement, transforms, and feature extraction.'
        Modules = @(
            'raw_pixel_unpacker',
            'bayer_unpacker',
            'demosaic_engine',
            'black_level_correction',
            'white_balance',
            'bad_pixel_correction',
            'lens_shading_correction',
            'color_correction_matrix',
            'gamma_lut',
            'histogram_engine',
            'ae_awb_af_statistics',
            'median_filter',
            'gaussian_blur',
            'bilateral_filter',
            'sharpening_filter',
            'sobel_edge',
            'canny_edge',
            'laplacian_filter',
            'morphology_erode',
            'morphology_dilate',
            'thresholding_block',
            'adaptive_thresholding',
            'clahe_engine',
            'integral_image',
            'crop_resize_rotate',
            'affine_warp',
            'remap_engine',
            'color_space_converter'
        )
    },
    [ordered]@{
        Name = 'video_processing_and_display_pipelines'
        Title = 'Video Processing and Display Pipelines'
        Description = 'Streaming video transport, frame composition, scaling, timing, and display-oriented processing blocks.'
        Modules = @(
            'video_timing_controller',
            'sync_generator',
            'sync_separator',
            'frame_buffer_reader',
            'frame_buffer_writer',
            'video_scaler',
            'deinterlacer',
            'chroma_resampler',
            'frame_rate_converter',
            'osd_engine',
            'alpha_blender',
            'video_mixer',
            'compositor',
            'test_pattern_generator',
            'hdmi_tx_wrapper',
            'hdmi_rx_wrapper',
            'csi2_rx_wrapper',
            'dsi_tx_wrapper',
            'displayport_tx_wrapper',
            'sdi_wrapper',
            'hdr_tone_mapper',
            'panel_timing_controller'
        )
    },
    [ordered]@{
        Name = 'audio_speech_and_acoustic_processing'
        Title = 'Audio, Speech, and Acoustic Processing'
        Description = 'Audio transport, filtering, spectral analysis, speech front-end, and microphone-array signal-processing blocks.'
        Modules = @(
            'i2s_rx_tx',
            'tdm_audio_rx_tx',
            'spdif_rx_tx',
            'pdm_decimator',
            'sample_rate_converter',
            'audio_fifo',
            'audio_mixer',
            'gain_block',
            'equalizer_biquad_bank',
            'crossover_filter_bank',
            'compressor_limiter',
            'noise_gate',
            'audio_agc',
            'voice_activity_detector',
            'pitch_detector',
            'spectrogram_engine',
            'mel_filter_bank',
            'mfcc_extractor',
            'acoustic_echo_canceller',
            'microphone_beamformer',
            'acoustic_localizer',
            'binaural_renderer'
        )
    },
    [ordered]@{
        Name = 'computer_vision_and_perception'
        Title = 'Computer Vision and Perception'
        Description = 'Structured perception modules for feature detection, geometric reasoning, object extraction, and tracking.'
        Modules = @(
            'connected_components_labeler',
            'blob_detector',
            'hough_transform',
            'corner_detector',
            'feature_extractor',
            'descriptor_generator',
            'descriptor_matcher',
            'optical_flow_estimator',
            'stereo_matcher',
            'disparity_refiner',
            'background_subtractor',
            'segmentation_postprocessor',
            'perspective_transform',
            'non_maximum_suppression',
            'bounding_box_decoder',
            'kalman_tracker',
            'multi_object_association',
            'occupancy_grid_builder'
        )
    },
    [ordered]@{
        Name = 'wireless_sdr_and_baseband'
        Title = 'Wireless, SDR, and Baseband'
        Description = 'Communication baseband and software-defined-radio modules for framing, coding, synchronization, and equalization.'
        Modules = @(
            'prbs_generator',
            'scrambler',
            'descrambler',
            'interleaver',
            'deinterleaver',
            'convolutional_encoder',
            'viterbi_decoder',
            'reed_solomon_codec',
            'bch_codec',
            'ldpc_codec',
            'polar_codec',
            'ofdm_modem_core',
            'cyclic_prefix_handler',
            'pilot_inserter_extractor',
            'qam_mapper_demapper',
            'timing_synchronizer',
            'carrier_recovery',
            'cfo_estimator',
            'channel_estimator',
            'equalizer_core',
            'mimo_detector',
            'harq_buffer',
            'framer_deframer',
            'correlator_bank'
        )
    },
    [ordered]@{
        Name = 'radar_processing'
        Title = 'Radar Processing'
        Description = 'Radar-centric DSP modules for chirp synthesis, range-Doppler processing, beamforming, and target extraction.'
        Modules = @(
            'chirp_generator',
            'dechirp_mixer',
            'iq_imbalance_corrector',
            'pulse_compression',
            'range_fft',
            'doppler_fft',
            'range_doppler_builder',
            'cfar_detector',
            'mti_filter',
            'clutter_suppressor',
            'angle_fft',
            'digital_beamformer',
            'array_calibration',
            'doa_estimator',
            'target_tracker',
            'micro_doppler_analyzer',
            'sar_backprojection_helper',
            'stap_research_block'
        )
    },
    [ordered]@{
        Name = 'sonar_and_array_acoustics'
        Title = 'Sonar and Array Acoustics'
        Description = 'Acoustic sensing and underwater array-processing blocks for active and passive sonar chains.'
        Modules = @(
            'ping_generator',
            'hydrophone_frontend_interface',
            'matched_filter',
            'delay_and_sum_beamformer',
            'bearing_estimator',
            'tdoa_estimator',
            'reverberation_suppressor',
            'passive_detector',
            'doppler_estimator',
            'target_tracker',
            'array_calibration',
            'passive_spectrogram',
            'click_detector',
            'sonar_data_framer'
        )
    },
    [ordered]@{
        Name = 'lidar_tof_and_3d_sensing'
        Title = 'LiDAR, ToF, and 3D Sensing'
        Description = 'Time-of-flight and ranging support blocks for pulsed lasers, point-cloud generation, and 3D depth pipelines.'
        Modules = @(
            'tdc_capture',
            'tof_histogrammer',
            'peak_detector',
            'multi_return_resolver',
            'walk_error_corrector',
            'laser_trigger_controller',
            'scan_pattern_generator',
            'point_cloud_packer',
            'voxel_filter',
            'timestamp_synchronizer',
            'range_calibration_engine',
            'reflectivity_estimator'
        )
    },
    [ordered]@{
        Name = 'gnss_navigation_and_sensor_fusion'
        Title = 'GNSS, Navigation, and Sensor Fusion'
        Description = 'Positioning, navigation, timing, and multi-sensor fusion modules for disciplined clocks and navigation stacks.'
        Modules = @(
            'prn_generator',
            'acquisition_correlator_bank',
            'code_tracking_dll',
            'carrier_tracking_pll',
            'frequency_locked_loop',
            'nav_bit_synchronizer',
            'ephemeris_decoder',
            'pseudorange_engine',
            'carrier_phase_engine',
            'imu_preintegration',
            'strapdown_integrator',
            'kalman_fusion_engine',
            'dead_reckoning_block',
            'disciplined_clock_controller',
            'pps_aligner'
        )
    },
    [ordered]@{
        Name = 'motor_control_and_digital_power'
        Title = 'Motor Control and Digital Power'
        Description = 'Control and transformation blocks for motors, drives, power conversion, and digitally controlled power electronics.'
        Modules = @(
            'center_aligned_pwm',
            'space_vector_pwm',
            'dead_time_inserter',
            'current_reconstruction',
            'clarke_transform',
            'park_transform',
            'inverse_park_transform',
            'foc_current_loop',
            'speed_loop_controller',
            'flux_observer',
            'speed_observer',
            'hall_sensor_decoder',
            'quadrature_encoder_decoder',
            'resolver_interface',
            'overcurrent_shutdown',
            'soft_start_controller',
            'pfc_controller',
            'smps_digital_compensator'
        )
    },
    [ordered]@{
        Name = 'robotics_industrial_automation_and_fieldbuses'
        Title = 'Robotics, Industrial Automation, and Fieldbuses'
        Description = 'Industrial control and communication support IP for motion, deterministic automation, and machine coordination.'
        Modules = @(
            'stepper_pulse_generator',
            'servo_loop_helper',
            'safety_interlock_logic',
            'ethercat_slave_block',
            'profinet_endpoint',
            'modbus_rtu_controller',
            'modbus_tcp_bridge',
            'canopen_helper',
            'timestamp_synchronizer',
            'motion_profile_generator',
            'kinematics_helper',
            'safe_io_voter',
            'machine_state_sequencer',
            'emergency_stop_latch'
        )
    },
    [ordered]@{
        Name = 'security_and_cryptography'
        Title = 'Security and Cryptography'
        Description = 'Hardware security primitives, secure-boot infrastructure, key management, and cryptographic accelerators.'
        Modules = @(
            'aes_core',
            'aes_gcm_engine',
            'chacha20_core',
            'poly1305_core',
            'sha2_engine',
            'sha3_engine',
            'hmac_engine',
            'cmac_engine',
            'rsa_modexp',
            'ecc_p256_scalar_mult',
            'trng_block',
            'drbg_block',
            'otp_efuse_controller',
            'key_ladder',
            'secure_boot_block',
            'anti_rollback_counter',
            'puf_interface',
            'tamper_monitor',
            'constant_time_compare'
        )
    },
    [ordered]@{
        Name = 'compression_coding_and_ecc_fec'
        Title = 'Compression, Coding, and ECC/FEC'
        Description = 'Coding and compression modules for resilience, bandwidth reduction, and framed transport robustness.'
        Modules = @(
            'run_length_codec',
            'huffman_codec',
            'arithmetic_coder',
            'golomb_rice_codec',
            'delta_encoder_decoder',
            'lz4_block',
            'deflate_building_block',
            'jpeg_dct_quantizer',
            'jpeg_huffman_block',
            'hamming_secded',
            'bch_codec',
            'reed_solomon_codec',
            'crc_family',
            'packet_framer',
            'packet_deframer',
            'interleaver',
            'deinterleaver',
            'entropy_adapter'
        )
    },
    [ordered]@{
        Name = 'ai_ml_acceleration'
        Title = 'AI/ML Acceleration'
        Description = 'Inference-centric compute blocks for neural-network execution, quantization flows, and post-processing.'
        Modules = @(
            'tensor_dma',
            'systolic_array',
            'gemm_engine',
            'conv2d_engine',
            'depthwise_conv_engine',
            'pointwise_conv_engine',
            'pooling_engine',
            'activation_unit',
            'batchnorm_layernorm',
            'softmax_block',
            'attention_score_unit',
            'qkv_projection_helper',
            'quantize_dequantize',
            'embedding_lookup',
            'sparse_decode_unit',
            'argmax_topk',
            'nms_block',
            'detector_postprocessor'
        )
    },
    [ordered]@{
        Name = 'biomedical_and_ultrasound'
        Title = 'Biomedical and Ultrasound'
        Description = 'Physiological signal-processing and ultrasound-focused modules for wearable, imaging, and medical instrumentation systems.'
        Modules = @(
            'ecg_bandpass_filter',
            'qrs_detector',
            'eeg_filter_bank',
            'pulse_oximetry_demodulator',
            'heart_rate_estimator',
            'respiration_rate_estimator',
            'ultrasound_beamformer',
            'doppler_flow_estimator',
            'motion_artifact_rejector',
            'bioimpedance_demodulator',
            'medical_data_framer',
            'patient_alarm_block'
        )
    },
    [ordered]@{
        Name = 'scientific_computing_and_specialty_sensing'
        Title = 'Scientific Computing and Specialty Sensing'
        Description = 'Numerical and instrumentation blocks for research systems, lab instruments, and uncommon sensing modalities.'
        Modules = @(
            'matrix_multiply_engine',
            'qr_decomposition_helper',
            'lu_decomposition_helper',
            'cholesky_helper',
            'monte_carlo_rng',
            'particle_filter_core',
            'correlation_matrix_builder',
            'high_speed_histogrammer',
            'finite_difference_stencil',
            'compressive_sensing_block',
            'hyperspectral_cube_unpacker',
            'spectral_calibration_engine',
            'fringe_phase_unwrapper',
            'interferometry_helper'
        )
    },
    [ordered]@{
        Name = 'debug_test_dft_safety_and_reliability'
        Title = 'Debug, Test, DFT, Safety, and Reliability'
        Description = 'Visibility, self-test, fault coverage, redundancy, and safety infrastructure for robust silicon and FPGA systems.'
        Modules = @(
            'jtag_tap',
            'boundary_scan_wrapper',
            'scan_controller',
            'mbist_controller',
            'lbist_controller',
            'memory_march_tester',
            'prbs_generator_checker',
            'bus_monitor',
            'trace_funnel',
            'event_recorder',
            'fault_injector',
            'error_logger',
            'assertion_monitor',
            'tmr_voter',
            'lockstep_comparator',
            'safe_state_controller',
            'brownout_fault_interface',
            'ecc_scrubber'
        )
    },
    [ordered]@{
        Name = 'processor_subsystems_and_accelerator_integration'
        Title = 'Processor Subsystems and Accelerator Integration'
        Description = 'Processor-adjacent IP for boot, interrupts, caching, dispatch, debug, and accelerator attachment.'
        Modules = @(
            'riscv_core_wrapper',
            'debug_module',
            'clint_block',
            'plic_block',
            'instruction_cache',
            'data_cache',
            'scratchpad_tcm',
            'boot_rom',
            'coprocessor_interface',
            'accelerator_dispatcher',
            'multicore_mailbox',
            'atomic_semaphore_block',
            'mmu_lite',
            'performance_counter_block'
        )
    },
    [ordered]@{
        Name = 'fpga_platform_support_and_reconfiguration'
        Title = 'FPGA Platform Support and Reconfiguration'
        Description = 'Vendor-facing wrapper IP for transceivers, clocking, startup, and runtime reconfiguration on FPGA platforms.'
        Modules = @(
            'transceiver_reset_fsm',
            'serdes_calibration_block',
            'mmcm_pll_wrapper',
            'iodelay_controller',
            'startup_sequencer',
            'icap_pcap_controller',
            'partial_reconfiguration_manager',
            'bitstream_loader',
            'ddr_phy_wrapper',
            'vendor_ram_wrapper',
            'vendor_dsp_wrapper',
            'transceiver_loopback_tester'
        )
    },
    [ordered]@{
        Name = 'aerospace_space_and_harsh_environment_systems'
        Title = 'Aerospace, Space, and Harsh-Environment Systems'
        Description = 'Mission-oriented communication, fault management, and radiation-aware support blocks for harsh deployments.'
        Modules = @(
            'spacewire_link_block',
            'ccsds_framer',
            'ccsds_deframer',
            'telecommand_packetizer',
            'telemetry_packetizer',
            'mil_std_1553_interface',
            'arinc429_helper',
            'time_triggered_scheduler',
            'radiation_memory_scrubber',
            'redundant_voter_fabric',
            'fault_management_unit',
            'health_monitor_block'
        )
    },
    [ordered]@{
        Name = 'graphics_hmi_and_display_composition'
        Title = 'Graphics, HMI, and Display Composition'
        Description = '2D graphics and display-layer composition modules for embedded user interfaces and operator panels.'
        Modules = @(
            'sprite_engine',
            'blitter',
            'line_draw_engine',
            'rectangle_fill_engine',
            'font_rom_renderer',
            'text_overlay',
            'cursor_overlay',
            'palette_lookup',
            'dithering_block',
            'touch_bridge',
            'frame_compositor',
            'ui_layer_mixer',
            'simple_2d_accelerator',
            'icon_cache'
        )
    }
)

New-Item -ItemType Directory -Path $domainsRoot -Force | Out-Null

foreach ($domain in $domains) {
    $domainPath = Join-Path $domainsRoot $domain.Name
    New-Item -ItemType Directory -Path $domainPath -Force | Out-Null

    foreach ($module in $domain.Modules) {
        $modulePath = Join-Path $domainPath $module
        New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
    }

    $content = @(
        "# $($domain.Title)",
        '',
        $domain.Description,
        '',
        '## Candidate Modules',
        ''
    )

    $content += $domain.Modules | ForEach-Object { '- `' + $_ + '`' }

    Set-Content -Path (Join-Path $domainPath 'MODULE_LIST.md') -Value $content -Encoding ascii
}
