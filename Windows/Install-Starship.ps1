[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installedPath = Join-Path $env:ProgramFiles 'starship\bin\starship.exe'

if ((Get-Command starship.exe -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $installedPath)) {
    Write-Host 'Starship is already installed.'
    return
}

if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
    throw 'Winget is required to install Starship. Install App Installer, then run Bootstrap.ps1 again.'
}

& winget.exe install --id Starship.Starship --exact --accept-package-agreements --accept-source-agreements
if ($LASTEXITCODE -ne 0) {
    throw "Winget failed to install Starship (exit $LASTEXITCODE)."
}

if (-not (Test-Path -LiteralPath $installedPath) -and -not (Get-Command starship.exe -ErrorAction SilentlyContinue)) {
    throw 'Starship installed, but starship.exe could not be located. Open a new terminal and run Bootstrap.ps1 again.'
}

Write-Host 'Installed Starship. New terminals will pick it up from PATH.'
