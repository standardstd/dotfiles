# Bootstrap script for Windows PowerShell
# Usage: .\bootstrap.ps1

$ErrorActionPreference = "Stop"

# Get script directory
$SCRIPT_DIR = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$DOTFILES = $SCRIPT_DIR

Write-Host "Bootstrapping dev environment from: $DOTFILES" -ForegroundColor Green
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "INFO: Running as Standard User." -ForegroundColor Cyan
    Write-Host "Developer Mode will be used for symlinks." -ForegroundColor Cyan
    Write-Host ""
}

# Run installation scripts
try {
    # Étape 1 : Installation des outils
    Write-Host "--- Step 1: Installing tools ---" -ForegroundColor Cyan
    & "$DOTFILES\scripts\install-tools.ps1"
    Write-Host ""
    
    # Étape 2 : Création des liens (Le "&" corrige ton erreur de privilèges)
    Write-Host "--- Step 2: Creating symlinks ---" -ForegroundColor Cyan
    & "$DOTFILES\scripts\symlink.ps1"
    Write-Host ""
    
    # Étape 3 : Extensions VS Code
    Write-Host "--- Step 3: Installing VS Code extensions ---" -ForegroundColor Cyan
    & "$DOTFILES\scripts\install-vscode-extensions.ps1"
    Write-Host ""
    
    Write-Host "[OK] Setup complete!" -ForegroundColor Green
}
catch {
    Write-Host "[!] Error during setup:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}