[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$managedDirectory = Join-Path $HOME '.config\glyphforged'
$managedProfile = Join-Path $managedDirectory 'Microsoft.PowerShell_profile.ps1'
$profileSource = Join-Path $PSScriptRoot 'PowerShell\Glyphforged.Profile.ps1'
$starshipSource = Join-Path $repoRoot 'Shared\starship.toml'
$starshipDirectory = Join-Path $HOME '.config'
$starshipDestination = Join-Path $starshipDirectory 'starship.toml'
$themeState = Join-Path $managedDirectory 'starship-theme'
$documents = [Environment]::GetFolderPath('MyDocuments')
$profilePaths = @(
    (Join-Path $documents 'PowerShell\Microsoft.PowerShell_profile.ps1'),
    (Join-Path $documents 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
)
$loader = ". '$managedProfile'"

New-Item -ItemType Directory -Force -Path $managedDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $starshipDirectory | Out-Null
Copy-Item -LiteralPath $profileSource -Destination $managedProfile -Force
Copy-Item -LiteralPath $starshipSource -Destination $starshipDestination -Force

if (Test-Path -LiteralPath $themeState) {
    $themeName = (Get-Content -LiteralPath $themeState -Raw).Trim()
    $starshipRaw = Get-Content -LiteralPath $starshipDestination -Raw
    if ($starshipRaw -match ('(?m)^\[palettes\.' + [regex]::Escape($themeName) + '\]$')) {
        $starshipRaw = $starshipRaw -replace '(?m)^palette = "[^"]+"', "palette = `"$themeName`""
        Set-Content -LiteralPath $starshipDestination -Value $starshipRaw -NoNewline -Encoding utf8
        Write-Host "Restored Starship theme: $themeName"
    }
}

foreach ($profilePath in $profilePaths) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $profilePath) | Out-Null
    if (-not (Test-Path -LiteralPath $profilePath)) {
        New-Item -ItemType File -Path $profilePath | Out-Null
    }

    if (-not (Select-String -LiteralPath $profilePath -SimpleMatch $loader -Quiet -ErrorAction SilentlyContinue)) {
        $backupPath = "$profilePath.dotfiles-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item -LiteralPath $profilePath -Destination $backupPath
        Add-Content -LiteralPath $profilePath -Value "`n# >>> Glyphforged dotfiles >>>`n$loader`n# <<< Glyphforged dotfiles <<<"
        Write-Host "Added the Glyphforged loader to $profilePath. Backup: $backupPath"
    }
    else {
        Write-Host "Glyphforged loader already present in $profilePath."
    }
}

Write-Host "Synced managed PowerShell settings to $managedProfile."
Write-Host "Synced Starship config to $starshipDestination."
