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
    throw 'Unable to locate OSS CAD Suite for width_converter verification.'
}

Use-OssCadSuiteEnvironment -Root $suiteRoot | Out-Null

$iverilog = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\iverilog.exe')
$vvp = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\vvp.exe')
$yosys = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\yosys.exe')
$sby = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\sby.exe')

$moduleRoot = Join-Path $workspaceRoot 'domains\core_rtl_infrastructure_and_glue\width_converter'
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

$simVvp = Join-Path $simOutRoot 'width_converter_tb.vvp'
$formalRunDir = Join-Path $formalOutRoot 'width_converter_formal'

Run-Step -Name 'width_converter simulation compile' -Command $iverilog -Arguments @(
    '-g2012',
    '-o',
    $simVvp,
    (Join-Path $rtlRoot 'width_converter.sv'),
    (Join-Path $simRoot 'width_converter_tb.sv')
)

Run-Step -Name 'width_converter simulation run' -Command $vvp -Arguments @($simVvp)

Run-Step -Name 'width_converter yosys synthesis sanity' -Command $yosys -Arguments @(
    '-p',
    ('read_verilog -sv ' + (Join-Path $rtlRoot 'width_converter.sv') + '; hierarchy -check -top width_converter; proc; opt; stat')
)

Run-Step -Name 'width_converter formal check' -Command $sby -Arguments @(
    '-f',
    'width_converter_formal.sby',
    '-d',
    $formalRunDir
) -WorkingDirectory $formalRoot

Write-Output ('width_converter verification complete. Outputs are in ' + $outRoot)
