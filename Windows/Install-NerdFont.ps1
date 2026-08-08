[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
# Nerd Fonts v3 registers this CaskaydiaCove Nerd Font Mono build as "CaskaydiaCove NFM".
$fontFace = 'CaskaydiaCove NFM'
$fontUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip'

function Test-FontInstalled {
    Add-Type -AssemblyName System.Drawing
    $installed = [System.Drawing.Text.InstalledFontCollection]::new()
    return $installed.Families.Name -contains $fontFace
}

if (Test-FontInstalled) {
    Write-Host "$fontFace is already installed."
    exit 0
}

$wingetPackage = 'NerdFonts.CaskaydiaCove'
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Checking Winget for $wingetPackage..."
    & winget search --id $wingetPackage --exact --accept-source-agreements 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        & winget install --id $wingetPackage --exact --accept-package-agreements --accept-source-agreements
        if (Test-FontInstalled) {
            Write-Host "$fontFace installed through Winget."
            Write-Warning 'Close and reopen Windows Terminal before testing glyphs.'
            exit 0
        }
    }

    Write-Warning "$wingetPackage is not available in the configured Winget sources; using the official Nerd Fonts release."
}
else {
    Write-Warning 'Winget is unavailable; using the official Nerd Fonts release.'
}

$temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-caskaydia-{0}" -f [guid]::NewGuid())
$archive = Join-Path $temporaryRoot 'CaskaydiaCove.zip'
$expanded = Join-Path $temporaryRoot 'expanded'

try {
    New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
    Invoke-WebRequest -Uri $fontUrl -OutFile $archive
    Expand-Archive -LiteralPath $archive -DestinationPath $expanded

    # Install only the monospaced CaskaydiaCove Nerd Font variants.
    $fontFiles = Get-ChildItem -Path $expanded -Recurse -File -Filter '*.ttf' |
        Where-Object { $_.Name -like 'CaskaydiaCoveNerdFontMono-*.ttf' }

    if (-not $fontFiles) {
        throw 'The Nerd Fonts archive did not contain the expected CaskaydiaCove Nerd Font Mono files.'
    }

    # This special shell folder performs a per-user font installation and registration.
    $fontShellFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    foreach ($fontFile in $fontFiles) {
        $fontShellFolder.CopyHere($fontFile.FullName, 0x14)
    }

    Start-Sleep -Milliseconds 500
    if (-not (Test-FontInstalled)) {
        throw "Windows did not register $fontFace. Re-run this script from an interactive PowerShell session."
    }

    Write-Host "$fontFace installed successfully."
    Write-Warning 'Close and reopen Windows Terminal before testing glyphs.'
}
finally {
    if (Test-Path -LiteralPath $temporaryRoot) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    }
}
