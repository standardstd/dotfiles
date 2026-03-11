# Bootstrap script for Windows PowerShell
# Usage: powershell -ExecutionPolicy Bypass -File bootstrap.ps1

$ErrorActionPreference = "Stop"

# Get script directory
$SCRIPT_DIR = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$DOTFILES = $SCRIPT_DIR

Write-Host "Bootstrapping dev environment from: $DOTFILES" -ForegroundColor Green
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "WARNING: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Some operations (like symlinks) may fail without admin privileges." -ForegroundColor Yellow
    Write-Host "Consider running: powershell -RunAs Administrator" -ForegroundColor Yellow
    Write-Host ""
}

# Run installation scripts
try {
    Write-Host "--- Step 1: Installing tools ---" -ForegroundColor Cyan
    & powershell -ExecutionPolicy Bypass -File "$DOTFILES\scripts\install-tools.ps1"
    Write-Host ""
    
    Write-Host "--- Step 2: Creating symlinks ---" -ForegroundColor Cyan
    & powershell -ExecutionPolicy Bypass -File "$DOTFILES\scripts\symlink.ps1"
    Write-Host ""
    
    Write-Host "--- Step 3: Installing VS Code extensions ---" -ForegroundColor Cyan
    & powershell -ExecutionPolicy Bypass -File "$DOTFILES\scripts\install-vscode-extensions.ps1"
    Write-Host ""
    
    Write-Host "[OK] Setup complete!" -ForegroundColor Green
}
catch {
    Write-Host "[!] Error during setup:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}