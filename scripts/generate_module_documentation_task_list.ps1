$workspaceRoot = Split-Path -Parent $PSScriptRoot
$domainsRoot = Join-Path $workspaceRoot 'domains'
$outputPath = Join-Path $workspaceRoot 'MODULE_DOCUMENTATION_TASK_LIST.md'

$preferredDomainOrder = @(
    'core_rtl_infrastructure_and_glue',
    'clocking_reset_power_and_timing',
    'arithmetic_and_numeric_computing',
    'buffering_memory_and_data_movement',
    'soc_interconnect_and_control_plane',
    'low_speed_peripheral_interfaces',
    'high_speed_serial_networking_and_packet_processing',
    'storage_and_external_memory_systems',
    'dsp_and_sampled_data_processing',
    'control_estimation_and_feedback_systems',
    'sensor_acquisition_and_instrumentation',
    'image_processing',
    'video_processing_and_display_pipelines',
    'audio_speech_and_acoustic_processing',
    'computer_vision_and_perception',
    'wireless_sdr_and_baseband',
    'radar_processing',
    'sonar_and_array_acoustics',
    'lidar_tof_and_3d_sensing',
    'gnss_navigation_and_sensor_fusion',
    'motor_control_and_digital_power',
    'robotics_industrial_automation_and_fieldbuses',
    'security_and_cryptography',
    'compression_coding_and_ecc_fec',
    'ai_ml_acceleration',
    'biomedical_and_ultrasound',
    'scientific_computing_and_specialty_sensing',
    'debug_test_dft_safety_and_reliability',
    'processor_subsystems_and_accelerator_integration',
    'fpga_platform_support_and_reconfiguration',
    'aerospace_space_and_harsh_environment_systems',
    'graphics_hmi_and_display_composition'
)

function Get-DomainTitle {
    param(
        [string]$DomainPath,
        [string]$FallbackName
    )

    $moduleListPath = Join-Path $DomainPath 'MODULE_LIST.md'
    if (Test-Path $moduleListPath) {
        $firstLine = Get-Content $moduleListPath | Select-Object -First 1
        if ($firstLine -and $firstLine.StartsWith('# ')) {
            return $firstLine.Substring(2)
        }
    }

    return (($FallbackName -split '_') | ForEach-Object {
        if ($_.Length -gt 0) {
            $_.Substring(0, 1).ToUpper() + $_.Substring(1)
        }
    }) -join ' '
}

$domainItems = foreach ($domainName in $preferredDomainOrder) {
    $domainPath = Join-Path $domainsRoot $domainName
    if (Test-Path $domainPath) {
        $moduleDirs = Get-ChildItem -Directory $domainPath | Sort-Object Name
        [pscustomobject]@{
            Name = $domainName
            Title = Get-DomainTitle -DomainPath $domainPath -FallbackName $domainName
            Path = $domainPath
            Modules = $moduleDirs
        }
    }
}

$domainCount = $domainItems.Count
$moduleCount = ($domainItems | ForEach-Object { $_.Modules.Count } | Measure-Object -Sum).Sum

$content = @(
    '# Module Documentation Task List',
    '',
    'This checklist tracks the creation of a deep, domain-specific `MODULE.md` file for every module folder under `domains/`.',
    '',
    '## Documentation Rules',
    '',
    '- Create `MODULE.md` inside each module folder.',
    '- Write each module document one by one; do not batch shallow placeholder text.',
    '- Keep documentation domain-specific even when module names repeat across domains.',
    '- Prefer depth over speed: explain purpose, interfaces, parameters, architecture, timing assumptions, verification ideas, integration notes, and edge cases.',
    '- Mark a task complete only when the module folder contains a substantive `MODULE.md` rather than a stub.',
    '',
    '## Suggested Structure For Each `MODULE.md`',
    '',
    '1. Overview',
    '2. Domain Context',
    '3. Problem Solved',
    '4. Typical Use Cases',
    '5. Interfaces and Signal-Level Behavior',
    '6. Parameters and Configuration Knobs',
    '7. Internal Architecture and Dataflow',
    '8. Clocking, Reset, CDC, and Timing Assumptions',
    '9. Latency, Throughput, and Resource Considerations',
    '10. Verification Strategy',
    '11. Integration Notes and Dependencies',
    '12. Edge Cases, Failure Modes, and Design Risks',
    '13. Related Modules In This Domain',
    '',
    '## Progress Summary',
    '',
    ('- Domains: ' + $domainCount),
    ('- Module folders: ' + $moduleCount),
    '',
    '## Task Checklist',
    ''
)

foreach ($domain in $domainItems) {
    $content += '### ' + $domain.Title
    $content += ''
    $content += '- [ ] Finish all deep, domain-specific `MODULE.md` files in `' + 'domains/' + $domain.Name + '/`.'
    $content += '- Modules in this domain: ' + $domain.Modules.Count
    $content += ''

    foreach ($module in $domain.Modules) {
        $content += '- [ ] Write deep, domain-specific `MODULE.md` for `' + 'domains/' + $domain.Name + '/' + $module.Name + '/MODULE.md`.'
    }

    $content += ''
}

Set-Content -Path $outputPath -Value $content -Encoding ascii
