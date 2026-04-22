$ErrorActionPreference = 'Stop'
$workspaceRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'verification_helpers.ps1')

function Assert-WorkspacePath {
    param([string]$PathToCheck)
    $resolvedWorkspace = (Resolve-Path $workspaceRoot).Path
    $resolvedTarget = (Resolve-Path $PathToCheck).Path
    if (-not $resolvedTarget.StartsWith($resolvedWorkspace, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to operate on path outside workspace: $resolvedTarget"
    }
}

function Run-Step {
    param(
        [string]$Name,
        [string]$Command,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory = $null
    )

    Write-Output ('Running ' + $Name + '...')
    $result = Invoke-CheckedCommand -Command $Command -Arguments $Arguments -WorkingDirectory $WorkingDirectory
    if (-not $result.Success) {
        Write-Output ($result.Output -join [Environment]::NewLine)
        throw ($Name + ' failed with exit code ' + $result.ExitCode)
    }
    if ($result.Output.Count -gt 0) {
        Write-Output ($result.Output -join [Environment]::NewLine)
    }
}

$suiteRoot = Get-OssCadSuiteRoot
if (-not $suiteRoot) {
    throw 'Unable to locate OSS CAD Suite for frequency_meter verification.'
}

Use-OssCadSuiteEnvironment -Root $suiteRoot | Out-Null

$iverilog = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\iverilog.exe')
$vvp = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\vvp.exe')
$yosys = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\yosys.exe')
$sby = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\sby.exe')

$moduleRoot = Join-Path $workspaceRoot 'domains\clocking_reset_power_and_timing\frequency_meter'
$rtlRoot = Join-Path $moduleRoot 'rtl'
$tbRoot = Join-Path $moduleRoot 'tb'
$simRoot = Join-Path $tbRoot 'sim'
$formalRoot = Join-Path $tbRoot 'formal'
$outRoot = Join-Path $tbRoot 'out'

if (Test-Path $outRoot) {
    Assert-WorkspacePath -PathToCheck $outRoot
    Remove-Item -LiteralPath $outRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $outRoot | Out-Null
$simOutRoot = Join-Path $outRoot 'sim'
$formalOutRoot = Join-Path $outRoot 'formal'
New-Item -ItemType Directory -Force -Path $simOutRoot | Out-Null
New-Item -ItemType Directory -Force -Path $formalOutRoot | Out-Null

$simVvp = Join-Path $simOutRoot 'frequency_meter_tb.vvp'
$formalRunDir = Join-Path $formalOutRoot 'frequency_meter_formal'

Run-Step -Name 'frequency_meter simulation compile' -Command $iverilog -Arguments @(
    '-g2012',
    '-o',
    $simVvp,
    (Join-Path $rtlRoot 'frequency_meter.sv'),
    (Join-Path $simRoot 'frequency_meter_tb.sv')
)

Run-Step -Name 'frequency_meter simulation run' -Command $vvp -Arguments @($simVvp)

Run-Step -Name 'frequency_meter yosys synthesis sanity' -Command $yosys -Arguments @(
    '-p',
    ('read_verilog -sv ' + (Join-Path $rtlRoot 'frequency_meter.sv') + '; hierarchy -check -top frequency_meter; proc; opt; stat')
)

Run-Step -Name 'frequency_meter formal check' -Command $sby -Arguments @(
    '-f',
    'frequency_meter_formal.sby',
    '-d',
    $formalRunDir
) -WorkingDirectory $formalRoot

Write-Output ('frequency_meter verification complete. Outputs are in ' + $outRoot)
