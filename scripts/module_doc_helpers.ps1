$workspaceRoot = Split-Path -Parent $PSScriptRoot

function Add-Bullets {
    param([string[]]$Items)

    if (-not $Items) {
        return @()
    }

    return $Items | ForEach-Object { '- ' + $_ }
}

function Write-ModuleDoc {
    param(
        [string]$Path,
        [string]$Title,
        [string]$DomainContext,
        [string]$Overview,
        [string]$Problem,
        [string[]]$UseCases,
        [string[]]$Interfaces,
        [string[]]$Parameters,
        [string]$Architecture,
        [string]$Assumptions,
        [string]$Performance,
        [string[]]$Verification,
        [string]$Integration,
        [string[]]$Risks,
        [string[]]$Related,
        [string]$AssumptionsHeading = 'Clocking, Reset, and Timing Assumptions'
    )

    $content = @(
        "# $Title",
        '',
        '## Overview',
        '',
        $Overview,
        '',
        '## Domain Context',
        '',
        $DomainContext,
        '',
        '## Problem Solved',
        '',
        $Problem,
        '',
        '## Typical Use Cases',
        ''
    )

    $content += Add-Bullets $UseCases
    $content += @(
        '',
        '## Interfaces and Signal-Level Behavior',
        ''
    )
    $content += Add-Bullets $Interfaces
    $content += @(
        '',
        '## Parameters and Configuration Knobs',
        ''
    )
    $content += Add-Bullets $Parameters
    $content += @(
        '',
        '## Internal Architecture and Dataflow',
        '',
        $Architecture,
        '',
        ('## ' + $AssumptionsHeading),
        '',
        $Assumptions,
        '',
        '## Latency, Throughput, and Resource Considerations',
        '',
        $Performance,
        '',
        '## Verification Strategy',
        ''
    )
    $content += Add-Bullets $Verification
    $content += @(
        '',
        '## Integration Notes and Dependencies',
        '',
        $Integration,
        '',
        '## Edge Cases, Failure Modes, and Design Risks',
        ''
    )
    $content += Add-Bullets $Risks
    $content += @(
        '',
        '## Related Modules In This Domain',
        ''
    )
    $content += Add-Bullets $Related
    $content += @(
        '',
        '## Documentation Status',
        '',
        "This MODULE.md is the current deep, domain-specific reference for the $Title module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly."
    )

    Set-Content -Path $Path -Value $content -Encoding ascii
}
