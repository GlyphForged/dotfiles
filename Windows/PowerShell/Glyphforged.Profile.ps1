# Managed by Glyphforged dotfiles. Personal PowerShell junk belongs in the
# normal profile, outside this file.
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

function src {
    . $PROFILE.CurrentUserCurrentHost
}

function Get-GlyphforgedThemes {
    $configFile = if ($env:STARSHIP_CONFIG) { $env:STARSHIP_CONFIG } else { Join-Path $HOME '.config\starship.toml' }
    if (-not (Test-Path -LiteralPath $configFile)) { return @() }
    $matches = [regex]::Matches((Get-Content -LiteralPath $configFile -Raw), '(?m)^\[palettes\.([^\]]+)\]$')
    return @($matches | ForEach-Object { $_.Groups[1].Value })
}

function theme {
    param([string]$Name = 'cyberpunk-vibrant')

    $configFile = if ($env:STARSHIP_CONFIG) { $env:STARSHIP_CONFIG } else { Join-Path $HOME '.config\starship.toml' }
    $stateDirectory = Join-Path $HOME '.config\glyphforged'
    $stateFile = Join-Path $stateDirectory 'starship-theme'
    $themes = @(Get-GlyphforgedThemes)
    if ($themes -notcontains $Name) {
        Write-Error "Unknown Starship theme: $Name. Available: $($themes -join ', ')"
        return
    }

    $updated = (Get-Content -LiteralPath $configFile -Raw) -replace '(?m)^palette = "[^"]+"', "palette = `"$Name`""
    Set-Content -LiteralPath $configFile -Value $updated -NoNewline -Encoding utf8
    New-Item -ItemType Directory -Force -Path $stateDirectory | Out-Null
    Set-Content -LiteralPath $stateFile -Value $Name -NoNewline -Encoding utf8
    Write-Host "Starship theme set to $Name."
}

function theme-subtle { theme cyberpunk-subtle }
function theme-vibrant { theme cyberpunk-vibrant }
function theme-neon { theme cyberpunk-neon }
function theme-mechanicus-subtle { theme mechanicus-subtle }
function theme-mechanicus-vibrant { theme mechanicus-vibrant }
function theme-mechanicus-neon { theme mechanicus-neon }
function theme-orkz { theme orkz }

$starshipCommand = Get-Command starship.exe -ErrorAction SilentlyContinue
$starshipPath = if ($starshipCommand) { $starshipCommand.Source } else { Join-Path $env:ProgramFiles 'starship\bin\starship.exe' }
if (-not $global:GlyphforgedStarshipInitialized -and (Test-Path -LiteralPath $starshipPath)) {
    Invoke-Expression (&$starshipPath init powershell)
    $global:GlyphforgedStarshipInitialized = $true
}
