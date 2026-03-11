param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Fonction utilitaire
function Run {
    param([string]$Command)

    if ($DryRun) {
        Write-Host "[DRY-RUN] $Command" -ForegroundColor DarkYellow
    } else {
        Invoke-Expression $Command
    }
}

# Aller à la racine du dépôt
$DOTFILES = Split-Path -Parent -Path $PSScriptRoot

Write-Host "--- Updating Dotfiles (Windows) ---" -ForegroundColor Cyan

# 1. Git Pull
Write-Host "Checking for updates on GitHub..." -ForegroundColor Yellow
Run "git -C `"$DOTFILES`" pull --rebase --autostash"

# 2. Winget
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Updating installed tools via Winget..." -ForegroundColor Yellow
    Run "winget upgrade --all --include-unknown"
}

# 3. Symlinks
Write-Host "Refreshing symlinks..." -ForegroundColor Yellow
if ($DryRun) {
    Write-Host "[DRY-RUN] Would run: $DOTFILES\scripts\symlink.ps1" -ForegroundColor DarkYellow
} else {
    & "$DOTFILES\scripts\symlink.ps1"
}

Write-Host "✓ Update complete!" -ForegroundColor Green