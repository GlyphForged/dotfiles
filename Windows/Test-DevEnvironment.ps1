[CmdletBinding()]
param(
    [switch]$SkipPowerShell,
    [switch]$SkipStarship,
    [switch]$SkipFont,
    [switch]$SkipTerminal,
    [switch]$SkipProfile
)

$ErrorActionPreference = 'Stop'
$failed = $false
$fontFace = 'CaskaydiaCove NFM'
$powerShell7Guid = '{574e775e-4f2a-5b96-ac1e-a2962a402336}'
$windowsPowerShellGuid = '{61c54bbd-c2c6-5271-96e7-009a87ff44bf}'
$settingsCandidates = @(
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json')
)
$managedProfile = Join-Path $HOME '.config\glyphforged\Microsoft.PowerShell_profile.ps1'
$profileLoader = ". '$managedProfile'"
$documents = [Environment]::GetFolderPath('MyDocuments')
$profilePaths = @(
    (Join-Path $documents 'PowerShell\Microsoft.PowerShell_profile.ps1'),
    (Join-Path $documents 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
)

function Write-CheckResult {
    param([string]$Name, [bool]$Passed, [bool]$Skipped = $false)
    if ($Skipped) {
        Write-Host "[SKIP] $Name"
    }
    elseif ($Passed) {
        Write-Host "[PASS] $Name"
    }
    else {
        Write-Host "[FAIL] $Name"
        $script:failed = $true
    }
}

Write-CheckResult 'PowerShell 7 available' ([bool](Get-Command pwsh.exe -ErrorAction SilentlyContinue)) $SkipPowerShell
$starshipInstalled = [bool](Get-Command starship.exe -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath (Join-Path $env:ProgramFiles 'starship\bin\starship.exe'))
Write-CheckResult 'Starship available on Windows' $starshipInstalled $SkipStarship

$fontInstalled = $false
if (-not $SkipFont) {
    Add-Type -AssemblyName System.Drawing
    $installed = [System.Drawing.Text.InstalledFontCollection]::new()
    $fontInstalled = $installed.Families.Name -contains $fontFace
}
Write-CheckResult "Windows font: $fontFace" $fontInstalled $SkipFont

$settingsPath = $settingsCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
$fontConfigured = $false
$retroConfigured = $false
$powerShellProfilesConfigured = $false
if ($settingsPath) {
    $rawSettings = Get-Content -LiteralPath $settingsPath -Raw
    $fontConfigured = $rawSettings -match ('"face"\s*:\s*"' + [regex]::Escape($fontFace) + '"')
    $retroConfigured = $rawSettings -match '"experimental\.retroTerminalEffect"\s*:\s*true'
    $powerShell7Named = (
        $rawSettings -match [regex]::Escape($powerShell7Guid) -and
        $rawSettings -match '"name"\s*:\s*"PowerShell 7"'
    )
    $windowsPowerShellNamed = $rawSettings -match '"name"\s*:\s*"Windows PowerShell 5\.1 \(legacy\)"'
    $windowsPowerShellIsDefault = $rawSettings -match ('"defaultProfile"\s*:\s*"' + [regex]::Escape($windowsPowerShellGuid) + '"')
    $powerShellProfilesConfigured = $powerShell7Named -and $windowsPowerShellNamed -and -not $windowsPowerShellIsDefault
}
Write-CheckResult "Windows Terminal profile-default font: $fontFace" $fontConfigured $SkipTerminal
Write-CheckResult 'Windows Terminal retro CRT effect' $retroConfigured $SkipTerminal
Write-CheckResult 'Windows Terminal distinguishes PowerShell 7 from legacy 5.1' $powerShellProfilesConfigured $SkipTerminal

$profilesConfigured = (Test-Path -LiteralPath $managedProfile)
foreach ($profilePath in $profilePaths) {
    $profilesConfigured = $profilesConfigured -and (Test-Path -LiteralPath $profilePath) -and (Select-String -LiteralPath $profilePath -SimpleMatch $profileLoader -Quiet -ErrorAction SilentlyContinue)
}
Write-CheckResult 'PowerShell 5.1 and 7 managed profile loaders' $profilesConfigured $SkipProfile

Write-Host ''
Write-Host 'Open NEW PowerShell and WSL tabs, then confirm these are icons rather than fallback boxes:'
Write-Host ([string]::Concat([char]0xF0C9, ' ', [char]0xF0C7, ' ', [char]0xF120, ' ', [char]0xF101))

if ($failed) { exit 1 }
