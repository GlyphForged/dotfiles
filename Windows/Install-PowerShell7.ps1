[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Find-PowerShell7 {
    $command = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }

    $candidate = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
    if (Test-Path -LiteralPath $candidate) { return $candidate }
    return $null
}

$pwshPath = Find-PowerShell7
if ($pwshPath) {
    Write-Host "PowerShell 7 is already installed: $pwshPath"
    return $pwshPath
}

if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
    throw 'Winget is required to install PowerShell 7. Install App Installer, then run Bootstrap.ps1 again.'
}

& winget.exe install --id Microsoft.PowerShell --exact --accept-package-agreements --accept-source-agreements
if ($LASTEXITCODE -ne 0) {
    throw "Winget failed to install PowerShell 7 (exit $LASTEXITCODE)."
}

$pwshPath = Find-PowerShell7
if (-not $pwshPath) {
    throw 'PowerShell 7 installed, but pwsh.exe could not be located. Open a new terminal and run Bootstrap.ps1 again.'
}

Write-Host "Installed PowerShell 7: $pwshPath"
return $pwshPath
