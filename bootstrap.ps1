# bootstrap.ps1 - Bootstrap script for Windows PowerShell
$ErrorActionPreference = "Stop"

# --- RECURSION GUARD ---
if ($env:TERM_PROGRAM -eq "vscode") {
    Write-Host ">>> Already inside VS Code terminal. Skipping bootstrap to prevent infinite loop." -ForegroundColor Cyan
    exit 0
}

# --- Détection du chemin ---
# MyCommand.Definition donne le chemin complet du script (ex: C:\Users\Reagan\dotfiles\bootstrap.ps1)
# Un seul Split-Path -Parent nous place dans le dossier 'dotfiles'
$DOTFILES = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# On définit la variable d'environnement pour la session actuelle
$env:DOTFILES = $DOTFILES

Write-Host "--- Bootstrapping dev environment from: $DOTFILES ---" -ForegroundColor Green
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "INFO: Running as Standard User." -ForegroundColor Cyan
    Write-Host "Note: Symlinks require 'Developer Mode' to be ON if not Admin." -ForegroundColor Cyan
    Write-Host ""
}

# Run installation scripts
try {
    # Étape 1 : Installation des outils de base (winget)
    Write-Host "--- Step 1: Installing tools ---" -ForegroundColor Cyan
    & "$DOTFILES\scripts\install-tools.ps1"
    Write-Host ""
    
    # Étape 2 : Création des liens symboliques (Profils, Git, VS Code)
    Write-Host "--- Step 2: Creating symlinks ---" -ForegroundColor Cyan
    & "$DOTFILES\scripts\symlink.ps1"
    Write-Host ""
    
    # Étape 3 : Extensions VS Code
    Write-Host "--- Step 3: Installing VS Code extensions ---" -ForegroundColor Cyan
    & "$DOTFILES\scripts\install-vscode-extensions.ps1"
    Write-Host ""
    
    Write-Host "===========================================" -ForegroundColor Green
    Write-Host "[OK] Global Setup Complete!" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Green
    Write-Host "IMPORTANT: Restart PowerShell 7 or VS Code to apply all changes." -ForegroundColor Yellow
    Write-Host "Try typing 'gs' or 'check-stack' after restart." -ForegroundColor Gray
}
catch {
    Write-Host "[!] Error during setup:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}