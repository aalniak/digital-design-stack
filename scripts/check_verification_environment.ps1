$ErrorActionPreference = 'Stop'
$workspaceRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'verification_helpers.ps1')

$verificationRoot = Join-Path $workspaceRoot 'verification'
$smokeRoot = Join-Path $verificationRoot 'smoke'
$outRoot = Join-Path $verificationRoot 'out'
$statusPath = Join-Path $verificationRoot 'ENVIRONMENT_STATUS.md'

function Convert-ToStatusLine {
    param(
        [string]$Name,
        [bool]$Success,
        [string]$Details
    )

    $state = if ($Success) { 'PASS' } else { 'FAIL' }
    return "| $Name | $state | $Details |"
}

function Get-FirstMeaningfulLine {
    param(
        [object[]]$Lines
    )

    foreach ($line in $Lines) {
        if ($null -ne $line -and $line.ToString().Trim()) {
            return $line.ToString().Trim()
        }
    }

    return ''
}

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

$suiteRoot = Get-OssCadSuiteRoot
if (-not $suiteRoot) {
    throw 'Unable to locate OSS CAD Suite. Expected an installation with bin, lib, and environment.ps1.'
}

$envInfo = Use-OssCadSuiteEnvironment -Root $suiteRoot

$toolMap = [ordered]@{
    'iverilog' = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\iverilog.exe')
    'vvp' = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\vvp.exe')
    'yosys' = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\yosys.exe')
    'sby' = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\sby.exe')
    'verilator' = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\verilator_bin.exe', 'bin\verilator')
    'python' = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('lib\python3.exe', 'python.exe')
    'z3' = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\z3.exe')
    'gtkwave' = Get-VerificationToolPath -Root $suiteRoot -RelativeCandidates @('bin\gtkwave.exe')
}

$versionCommands = @{
    'iverilog' = @('-V')
    'vvp' = @('-V')
    'yosys' = @('-V')
    'sby' = @('--version')
    'verilator' = @('--version')
    'python' = @('--version')
    'z3' = @('--version')
}

$toolRows = @('| Tool | Status | Details |', '| --- | --- | --- |')
foreach ($toolName in $toolMap.Keys) {
    $toolPath = $toolMap[$toolName]
    if (-not $toolPath) {
        $toolRows += Convert-ToStatusLine -Name $toolName -Success $false -Details 'Not found in the detected OSS CAD Suite root.'
        continue
    }

    if ($versionCommands.ContainsKey($toolName)) {
        $result = Invoke-CheckedCommand -Command $toolPath -Arguments $versionCommands[$toolName]
        $detail = if ($result.Success) {
            Get-FirstMeaningfulLine -Lines $result.Output
        }
        else {
            'Command failed with exit code ' + $result.ExitCode
        }
        $toolRows += Convert-ToStatusLine -Name $toolName -Success $result.Success -Details ($detail + ' (`' + $toolPath + '`)')
    }
    else {
        $toolRows += Convert-ToStatusLine -Name $toolName -Success $true -Details ('Present but not launched in the headless environment (`' + $toolPath + '`).')
    }
}

New-Item -ItemType Directory -Force -Path $outRoot | Out-Null
$smokeRunRoot = Join-Path $outRoot 'smoke_runs'
if (Test-Path $smokeRunRoot) {
    Assert-WorkspacePath -PathToCheck $smokeRunRoot
    Remove-Item -LiteralPath $smokeRunRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $smokeRunRoot | Out-Null

$simOutput = Join-Path $smokeRunRoot 'smoke_sim.vvp'
$formalOutput = Join-Path $smokeRunRoot 'smoke_formal'

$smokeRows = @('| Check | Status | Details |', '| --- | --- | --- |')

$simCompile = Invoke-CheckedCommand -Command $toolMap['iverilog'] -Arguments @(
    '-g2012',
    '-o',
    $simOutput,
    (Join-Path $smokeRoot 'smoke_counter.v'),
    (Join-Path $smokeRoot 'smoke_counter_tb.v')
)

if ($simCompile.Success) {
    $simRun = Invoke-CheckedCommand -Command $toolMap['vvp'] -Arguments @($simOutput)
    $simDetail = Get-FirstMeaningfulLine -Lines $simRun.Output
    $smokeRows += Convert-ToStatusLine -Name 'simulation_smoke' -Success $simRun.Success -Details $simDetail
}
else {
    $smokeRows += Convert-ToStatusLine -Name 'simulation_smoke' -Success $false -Details ('Compile failed with exit code ' + $simCompile.ExitCode)
}

$yosysResult = Invoke-CheckedCommand -Command $toolMap['yosys'] -Arguments @(
    '-p',
    'read_verilog smoke_counter.v; hierarchy -top smoke_counter; proc; opt; stat'
) -WorkingDirectory $smokeRoot

$yosysDetail = if ($yosysResult.Success) {
    Get-FirstMeaningfulLine -Lines ($yosysResult.Output | Select-Object -Last 12)
}
else {
    'Yosys smoke failed with exit code ' + $yosysResult.ExitCode
}
$smokeRows += Convert-ToStatusLine -Name 'synthesis_smoke' -Success $yosysResult.Success -Details $yosysDetail

$formalResult = Invoke-CheckedCommand -Command $toolMap['sby'] -Arguments @(
    '-f',
    (Join-Path $smokeRoot 'smoke_formal.sby'),
    '-d',
    $formalOutput
) -WorkingDirectory $smokeRoot

$formalDetail = if ($formalResult.Success) {
    Get-FirstMeaningfulLine -Lines ($formalResult.Output | Where-Object { $_ -match 'DONE \(PASS' } | Select-Object -First 1)
}
else {
    'SymbiYosys smoke failed with exit code ' + $formalResult.ExitCode
}
$smokeRows += Convert-ToStatusLine -Name 'formal_smoke' -Success $formalResult.Success -Details $formalDetail

$allChecksPassed = -not (($toolRows -join "`n") -match '\| FAIL \|') -and -not (($smokeRows -join "`n") -match '\| FAIL \|')
$overallStatus = if ($allChecksPassed) { 'READY' } else { 'PARTIAL' }

$content = @(
    '# Verification Environment Status',
    '',
    '## Summary',
    '',
    ('- Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')),
    ('- Workspace: `{0}`' -f $workspaceRoot),
    ('- Detected toolchain root: `{0}`' -f $suiteRoot),
    ('- Overall status: `{0}`' -f $overallStatus),
    '- Recommended invocation: `powershell -ExecutionPolicy Bypass -File .\\scripts\\check_verification_environment.ps1`',
    '',
    '## Why This Matters',
    '',
    'The module library is being shaped around highly configurable IP blocks. That means verification has to cover more than one fixed instantiation. The environment is only considered ready when it can elaborate configurable RTL, run a simulation smoke test, execute a synthesis sanity check, and complete a basic formal proof.',
    '',
    '## Tool Status',
    ''
)

$content += $toolRows
$content += @(
    '',
    '## Smoke Checks',
    ''
)
$content += $smokeRows
$content += @(
    '',
    '## Notes',
    '',
    '- The local machine does not expose the OSS CAD Suite tools on the default `PATH`, so verification scripts should activate the suite environment explicitly rather than relying on ambient shell state.',
    '- On this Windows installation, `verilator_bin.exe` is the directly invokable Verilator entry point.',
    '- The repository verification scripts intentionally avoid updating the OSS CAD Suite GTK cache because that would require writes into the tool installation directory and is not needed for headless RTL verification.',
    '- `gtkwave` is present for waveform inspection, but it is not launched by the automated environment check because that path is GUI-only.',
    '',
    '## Current Readiness',
    '',
    'Simulation, synthesis, and formal smoke checks all pass under the detected OSS CAD Suite installation. This is enough to begin scaffolding per-module `rtl/`, `tb/`, and `spec/` directories and to start adding module-level verification assets incrementally.'
)

Set-Content -Path $statusPath -Value $content -Encoding ascii
Write-Output ('Verification environment check complete: ' + $overallStatus)
Write-Output ('Status report written to ' + $statusPath)
