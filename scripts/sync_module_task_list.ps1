$workspaceRoot = Split-Path -Parent $PSScriptRoot
$taskListPath = Join-Path $workspaceRoot 'MODULE_DOCUMENTATION_TASK_LIST.md'
$lines = Get-Content $taskListPath
$moduleDocCount = (Get-ChildItem -Recurse -Filter MODULE.md (Join-Path $workspaceRoot 'domains') | Measure-Object).Count

$updated = foreach ($line in $lines) {
    if ($line -match '^- \[[ x]\] Write deep, domain-specific `MODULE.md` for `([^`]+)`\.$') {
        $relativePath = $matches[1]
        if (Test-Path (Join-Path $workspaceRoot $relativePath)) {
            '- [x] Write deep, domain-specific `MODULE.md` for `' + $relativePath + '`.'
        }
        else {
            '- [ ] Write deep, domain-specific `MODULE.md` for `' + $relativePath + '`.'
        }
    }
    elseif ($line -match '^- \[[ x]\] Finish all deep, domain-specific `MODULE.md` files in `domains/([^`]+)/`\.$') {
        $domainName = $matches[1]
        $domainPath = Join-Path $workspaceRoot ('domains\' + $domainName)
        $moduleDirs = Get-ChildItem -Directory $domainPath
        $missing = $moduleDirs | Where-Object { -not (Test-Path (Join-Path $_.FullName 'MODULE.md')) }
        if ($moduleDirs.Count -gt 0 -and $missing.Count -eq 0) {
            '- [x] Finish all deep, domain-specific `MODULE.md` files in `domains/' + $domainName + '/`.'
        }
        else {
            '- [ ] Finish all deep, domain-specific `MODULE.md` files in `domains/' + $domainName + '/`.'
        }
    }
    elseif ($line -match '^- Modules documented: \d+ / 553$') {
        '- Modules documented: ' + $moduleDocCount + ' / 553'
    }
    else {
        $line
    }
}

Set-Content -Path $taskListPath -Value $updated -Encoding ascii
