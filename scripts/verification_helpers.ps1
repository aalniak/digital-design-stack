$workspaceRoot = Split-Path -Parent $PSScriptRoot

function Get-OssCadSuiteRoot {
    param(
        [string[]]$AdditionalCandidates = @()
    )

    $candidates = @(
        $env:OSS_CAD_SUITE,
        $env:YOSYSHQ_ROOT,
        'C:\Users\arda\tools\oss-cad-suite\oss-cad-suite',
        'C:\Users\arda\tools\oss-cad-suite',
        'C:\oss-cad-suite\oss-cad-suite',
        'C:\oss-cad-suite',
        'C:\tools\oss-cad-suite\oss-cad-suite',
        'C:\tools\oss-cad-suite'
    ) + $AdditionalCandidates

    foreach ($candidate in ($candidates | Where-Object { $_ } | Select-Object -Unique)) {
        $normalized = $candidate.TrimEnd('\')
        if (
            (Test-Path (Join-Path $normalized 'bin')) -and
            (Test-Path (Join-Path $normalized 'lib')) -and
            (Test-Path (Join-Path $normalized 'environment.ps1'))
        ) {
            return (Resolve-Path $normalized).Path
        }
    }

    return $null
}

function Add-PathEntry {
    param(
        [string]$Entry
    )

    if (-not $Entry) {
        return
    }

    $parts = $env:PATH -split ';' | Where-Object { $_ }
    if ($parts -notcontains $Entry) {
        $env:PATH = $Entry + ';' + $env:PATH
    }
}

function Use-OssCadSuiteEnvironment {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $resolvedRoot = (Resolve-Path $Root).Path
    $binPath = Join-Path $resolvedRoot 'bin'
    $libPath = Join-Path $resolvedRoot 'lib'

    $env:YOSYSHQ_ROOT = $resolvedRoot.TrimEnd('\') + '\'
    $env:SSL_CERT_FILE = Join-Path $resolvedRoot 'etc\cacert.pem'
    Add-PathEntry -Entry $libPath
    Add-PathEntry -Entry $binPath
    $env:PYTHON_EXECUTABLE = Join-Path $resolvedRoot 'lib\python3.exe'
    $env:QT_PLUGIN_PATH = Join-Path $resolvedRoot 'lib\qt5\plugins'
    $env:QT_LOGGING_RULES = '*=false'
    $env:GTK_EXE_PREFIX = $resolvedRoot
    $env:GTK_DATA_PREFIX = $resolvedRoot
    $env:GDK_PIXBUF_MODULEDIR = Join-Path $resolvedRoot 'lib\gdk-pixbuf-2.0\2.10.0\loaders'
    $env:GDK_PIXBUF_MODULE_FILE = Join-Path $resolvedRoot 'lib\gdk-pixbuf-2.0\2.10.0\loaders.cache'

    return @{
        Root = $resolvedRoot
        Bin = $binPath
        Lib = $libPath
        Python = $env:PYTHON_EXECUTABLE
    }
}

function Get-VerificationToolPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string[]]$RelativeCandidates
    )

    foreach ($relativePath in $RelativeCandidates) {
        $candidate = Join-Path $Root $relativePath
        if (Test-Path $candidate) {
            return (Resolve-Path $candidate).Path
        }
    }

    return $null
}

function Format-CommandLine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [string[]]$Arguments = @()
    )

    if (-not $Arguments -or $Arguments.Count -eq 0) {
        return $Command
    }

    return $Command + ' ' + ($Arguments -join ' ')
}

function Convert-ToCmdArgument {
    param(
        [AllowEmptyString()]
        [string]$Argument
    )

    if ($null -eq $Argument) {
        return '""'
    }

    if ($Argument -match '[\s"&|<>^]') {
        return '"' + ($Argument -replace '"', '""') + '"'
    }

    return $Argument
}

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory = $null
    )

    $previousLocation = $null
    if ($WorkingDirectory) {
        $previousLocation = Get-Location
        Push-Location $WorkingDirectory
    }

    try {
        $commandLine = (Convert-ToCmdArgument -Argument $Command)
        if ($Arguments.Count -gt 0) {
            $quotedArguments = $Arguments | ForEach-Object { Convert-ToCmdArgument -Argument $_ }
            $commandLine += ' ' + ($quotedArguments -join ' ')
        }
        $commandLine += ' 2>&1'

        $output = & cmd.exe /d /c $commandLine
        $exitCode = $LASTEXITCODE
    }
    finally {
        if ($previousLocation) {
            Pop-Location
        }
    }

    return @{
        Command = $Command
        Arguments = $Arguments
        ExitCode = $exitCode
        Output = @($output)
        Success = ($exitCode -eq 0)
    }
}
