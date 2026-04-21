$ErrorActionPreference = 'Stop'
$workspaceRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'verification_helpers.ps1')

function Assert-WorkspacePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathToCheck
    )

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

    return $result
}

$suiteRoot = Get-OssCadSuiteRoot
if (-not $suiteRoot) {
    throw 'Unable to locate OSS CAD Suite for async_fifo verification.'
}

Use-OssCadSuiteEnvironment -Root $suiteRoot | Out-Null

$iverilog = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\iverilog.exe')
$vvp = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\vvp.exe')
$yosys = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\yosys.exe')
$sby = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\sby.exe')

$moduleRoot = Join-Path $workspaceRoot 'domains\core_rtl_infrastructure_and_glue\async_fifo'
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

$nativeVvp = Join-Path $simOutRoot 'async_fifo_native_tb.vvp'
$streamVvp = Join-Path $simOutRoot 'async_fifo_stream_tb.vvp'
$packetVvp = Join-Path $simOutRoot 'async_fifo_packet_tb.vvp'
$formalRunDir = Join-Path $formalOutRoot 'async_fifo_core_formal'

$null = Run-Step -Name 'native simulation compile' -Command $iverilog -Arguments @(
    '-g2012',
    '-o',
    $nativeVvp,
    (Join-Path $rtlRoot 'async_fifo_core.sv'),
    (Join-Path $rtlRoot 'async_fifo_native.sv'),
    (Join-Path $simRoot 'async_fifo_native_tb.sv')
)

$null = Run-Step -Name 'native simulation run' -Command $vvp -Arguments @($nativeVvp)

$null = Run-Step -Name 'stream simulation compile' -Command $iverilog -Arguments @(
    '-g2012',
    '-o',
    $streamVvp,
    (Join-Path $rtlRoot 'async_fifo_core.sv'),
    (Join-Path $rtlRoot 'async_fifo_stream.sv'),
    (Join-Path $simRoot 'async_fifo_stream_tb.sv')
)

$null = Run-Step -Name 'stream simulation run' -Command $vvp -Arguments @($streamVvp)

$null = Run-Step -Name 'packet simulation compile' -Command $iverilog -Arguments @(
    '-g2012',
    '-o',
    $packetVvp,
    (Join-Path $rtlRoot 'async_fifo_core.sv'),
    (Join-Path $rtlRoot 'async_fifo_stream.sv'),
    (Join-Path $rtlRoot 'async_fifo_packet.sv'),
    (Join-Path $simRoot 'async_fifo_packet_tb.sv')
)

$null = Run-Step -Name 'packet simulation run' -Command $vvp -Arguments @($packetVvp)

$null = Run-Step -Name 'yosys synthesis sanity' -Command $yosys -Arguments @(
    '-p',
    (
        'read_verilog -sv ' +
        (Join-Path $rtlRoot 'async_fifo_core.sv') + ' ' +
        (Join-Path $rtlRoot 'async_fifo_native.sv') + ' ' +
        (Join-Path $rtlRoot 'async_fifo_stream.sv') + ' ' +
        (Join-Path $rtlRoot 'async_fifo_packet.sv') + '; ' +
        'hierarchy -check -top async_fifo_packet; proc; opt; stat'
    )
)

$null = Run-Step -Name 'formal proof' -Command $sby -Arguments @(
    '-f',
    'async_fifo_core_formal.sby',
    '-d',
    $formalRunDir
) -WorkingDirectory $formalRoot

Write-Output ('async_fifo verification complete. Outputs are in ' + $outRoot)
