[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$fontFace = 'CaskaydiaCove NFM'
$powerShell7Guid = '{574e775e-4f2a-5b96-ac1e-a2962a402336}'
$windowsPowerShellGuid = '{61c54bbd-c2c6-5271-96e7-009a87ff44bf}'
$powerShell7Name = 'PowerShell 7'
$windowsPowerShellName = 'Windows PowerShell 5.1 (legacy)'
$settingsCandidates = @(
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json')
)
$settingsPath = $settingsCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

if (-not $settingsPath) {
    throw 'Windows Terminal settings.json was not found. Install and open Windows Terminal once, then re-run this script.'
}

$rawSettings = Get-Content -LiteralPath $settingsPath -Raw
if ($rawSettings -match '(?m)^\s*(//|/\*)') {
    throw "Refusing to rewrite JSON-with-comments at $settingsPath. Merge Windows/windows-terminal.settings.jsonc manually."
}

try {
    $settings = $rawSettings | ConvertFrom-Json
}
catch {
    throw "Unable to parse $settingsPath. Merge Windows/windows-terminal.settings.jsonc manually. $($_.Exception.Message)"
}

if (-not $settings.profiles) {
    $settings | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{})
}
if (-not $settings.profiles.defaults) {
    $settings.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{})
}
if (-not $settings.profiles.defaults.font) {
    $settings.profiles.defaults | Add-Member -NotePropertyName font -NotePropertyValue ([pscustomobject]@{})
}
if (-not $settings.profiles.list) {
    $settings.profiles | Add-Member -NotePropertyName list -NotePropertyValue @()
}

$powerShell7ProfileAdded = $false
$powerShell7Profile = @($settings.profiles.list) | Where-Object { $_.guid -eq $powerShell7Guid } | Select-Object -First 1
if (-not $powerShell7Profile) {
    $powerShell7Profile = [pscustomobject]@{
        commandline = '%ProgramFiles%\PowerShell\7\pwsh.exe'
        guid = $powerShell7Guid
        hidden = $false
        name = $powerShell7Name
    }
    $settings.profiles.list = @($settings.profiles.list) + $powerShell7Profile
    $powerShell7ProfileAdded = $true
}

$windowsPowerShellProfile = @($settings.profiles.list) | Where-Object { $_.guid -eq $windowsPowerShellGuid } | Select-Object -First 1
$profileNamesConfigured = (
    $powerShell7Profile.name -eq $powerShell7Name -and
    (-not $windowsPowerShellProfile -or $windowsPowerShellProfile.name -eq $windowsPowerShellName)
)
$defaultAvoidsWindowsPowerShell = $settings.defaultProfile -ne $windowsPowerShellGuid

if (
    $settings.profiles.defaults.font.face -eq $fontFace -and
    $settings.profiles.defaults.'experimental.retroTerminalEffect' -eq $true -and
    -not $powerShell7ProfileAdded -and
    $profileNamesConfigured -and
    $defaultAvoidsWindowsPowerShell
) {
    Write-Host "Windows Terminal already uses $fontFace, the retro effect, and clearly labeled PowerShell profiles."
    return
}

$settings.profiles.defaults.font | Add-Member -NotePropertyName face -NotePropertyValue $fontFace -Force
$settings.profiles.defaults | Add-Member -NotePropertyName 'experimental.retroTerminalEffect' -NotePropertyValue $true -Force
$powerShell7Profile.name = $powerShell7Name
if ($windowsPowerShellProfile) {
    $windowsPowerShellProfile.name = $windowsPowerShellName
}
if ($settings.defaultProfile -eq $windowsPowerShellGuid) {
    $settings.defaultProfile = $powerShell7Guid
}

$backupPath = "$settingsPath.dotfiles-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
Copy-Item -LiteralPath $settingsPath -Destination $backupPath
$settings | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $settingsPath -Encoding utf8

Write-Host "Configured $fontFace, the retro effect, and unambiguous PowerShell 7/5.1 profile names."
Write-Host "Backup: $backupPath"
Write-Warning 'Close and reopen Windows Terminal before testing glyphs or the CRT effect.'
