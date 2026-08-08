[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$errorsFound = @()
Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -Filter '*.ps1' | ForEach-Object {
    $tokens = $null
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$parseErrors)
    foreach ($parseError in $parseErrors) {
        $errorsFound += "$($_.FullName): $($parseError.Message)"
    }
}

if ($errorsFound.Count) {
    $errorsFound | ForEach-Object { Write-Error $_ }
    exit 1
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$starshipConfig = Join-Path $repoRoot 'Shared\starship.toml'
$profileSource = Join-Path $PSScriptRoot 'PowerShell\Glyphforged.Profile.ps1'
$paletteNames = @([regex]::Matches((Get-Content -LiteralPath $starshipConfig -Raw), '(?m)^\[palettes\.([^\]]+)\]$') | ForEach-Object { $_.Groups[1].Value })
$aliasTargets = @([regex]::Matches((Get-Content -LiteralPath $profileSource -Raw), '(?m)^function theme-[^ ]+ \{ theme ([^ }]+) \}$') | ForEach-Object { $_.Groups[1].Value })

foreach ($target in $aliasTargets) {
    if ($paletteNames -notcontains $target) {
        Write-Error "PowerShell theme shortcut targets a missing palette: $target"
        exit 1
    }
}

$terminalSettingsScript = Join-Path $PSScriptRoot 'Set-WindowsTerminalSettings.ps1'
$terminalSettingsRaw = Get-Content -LiteralPath $terminalSettingsScript -Raw
foreach ($expectedName in @('PowerShell 7', 'Windows PowerShell 5.1 (legacy)')) {
    if ($terminalSettingsRaw -notmatch [regex]::Escape($expectedName)) {
        Write-Error "Windows Terminal setup is missing the profile label: $expectedName"
        exit 1
    }
}

Write-Host "PowerShell syntax and theme parity: PASS ($($paletteNames.Count) palettes)"
