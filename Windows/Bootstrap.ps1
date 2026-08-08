[CmdletBinding()]
param(
    [switch]$SkipPowerShellInstall,
    [switch]$SkipStarshipInstall,
    [switch]$SkipFontInstall,
    [switch]$SkipTerminalSettings,
    [switch]$SkipPowerShellProfile,
    [switch]$RelaunchedByPwsh
)

$ErrorActionPreference = 'Stop'

$pwshPath = $null
if (-not $SkipPowerShellInstall) {
    $pwshPath = & (Join-Path $PSScriptRoot 'Install-PowerShell7.ps1')
}
else {
    $pwshCommand = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($pwshCommand) { $pwshPath = $pwshCommand.Source }
}

if ($PSVersionTable.PSVersion.Major -lt 7) {
    if (-not $pwshPath) {
        throw 'PowerShell 7 is required. Re-run without -SkipPowerShellInstall.'
    }
    if ($RelaunchedByPwsh) {
        throw 'Bootstrap relaunch under PowerShell 7 failed.'
    }

    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath, '-RelaunchedByPwsh')
    foreach ($switchName in @('SkipPowerShellInstall', 'SkipStarshipInstall', 'SkipFontInstall', 'SkipTerminalSettings', 'SkipPowerShellProfile')) {
        if ((Get-Variable -Name $switchName -ValueOnly)) { $arguments += "-$switchName" }
    }
    & $pwshPath @arguments
    exit $LASTEXITCODE
}

if (-not $SkipStarshipInstall) {
    & (Join-Path $PSScriptRoot 'Install-Starship.ps1')
}
if (-not $SkipFontInstall) {
    & (Join-Path $PSScriptRoot 'Install-NerdFont.ps1')
}
if (-not $SkipTerminalSettings) {
    & (Join-Path $PSScriptRoot 'Set-WindowsTerminalSettings.ps1')
}
if (-not $SkipPowerShellProfile) {
    & (Join-Path $PSScriptRoot 'Sync-PowerShellProfile.ps1')
}

$testArguments = @{}
if ($SkipPowerShellInstall) { $testArguments.SkipPowerShell = $true }
if ($SkipStarshipInstall) { $testArguments.SkipStarship = $true }
if ($SkipFontInstall) { $testArguments.SkipFont = $true }
if ($SkipTerminalSettings) { $testArguments.SkipTerminal = $true }
if ($SkipPowerShellProfile) { $testArguments.SkipProfile = $true }
& (Join-Path $PSScriptRoot 'Test-DevEnvironment.ps1') @testArguments
