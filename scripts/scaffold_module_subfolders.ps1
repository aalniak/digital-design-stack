$workspaceRoot = Split-Path -Parent $PSScriptRoot
$domainsRoot = Join-Path $workspaceRoot 'domains'
$subfolders = @('rtl', 'tb', 'spec')

$moduleDirs = Get-ChildItem -Directory $domainsRoot | ForEach-Object {
    Get-ChildItem -Directory $_.FullName
}

$createdFolders = 0
$existingFolders = 0
$createdPlaceholders = 0

foreach ($moduleDir in $moduleDirs) {
    foreach ($subfolder in $subfolders) {
        $target = Join-Path $moduleDir.FullName $subfolder
        if (-not (Test-Path $target)) {
            New-Item -ItemType Directory -Force -Path $target | Out-Null
            $createdFolders++
        }
        else {
            $existingFolders++
        }

        $placeholder = Join-Path $target '.gitkeep'
        if (-not (Test-Path $placeholder)) {
            New-Item -ItemType File -Path $placeholder | Out-Null
            $createdPlaceholders++
        }
    }
}

Write-Output ('Modules discovered: ' + $moduleDirs.Count)
Write-Output ('Subfolders created: ' + $createdFolders)
Write-Output ('Subfolders already present: ' + $existingFolders)
Write-Output ('Placeholder files created: ' + $createdPlaceholders)
