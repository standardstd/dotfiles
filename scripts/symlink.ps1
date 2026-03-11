# symlink.ps1 - Create symlinks for dotfiles on Windows
# Usage: powershell -ExecutionPolicy Bypass -File scripts\symlink.ps1
# Note: Requires Administrator privileges for symlinks

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$DOTFILES = Split-Path -Parent -Path $SCRIPT_DIR

Write-Host "Installing dotfiles from: $DOTFILES" -ForegroundColor Green
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "WARNING: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Symlinks may fail. Consider running as Administrator." -ForegroundColor Yellow
    Write-Host ""
}

function Create-SymlinkSafely {
    param(
        [string]$Source,
        [string]$Target
    )
    
    if (-not (Test-Path $Source)) {
        # Remplacement de ⚠ par [!]
        Write-Host "[!] Source not found: $Source" -ForegroundColor Yellow
        return $false
    }
    
    # Ensure target parent directory exists
    $targetParent = Split-Path -Parent $Target
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }
    
    # Backup existing file if it exists and is not a symlink
    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Host "  Replacing existing symlink: $Target" -ForegroundColor Yellow
            Remove-Item $Target -Force
        }
        else {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backup = "$Target.backup.$timestamp"
            Write-Host "  Backing up existing file to: $backup" -ForegroundColor Yellow
            Move-Item $Target $backup -Force
        }
    }
    
    # Create symlink
    try {
        New-Item -ItemType SymbolicLink -Path $Target -Value $Source -Force | Out-Null
        # Remplacement de ✓ par [OK]
        Write-Host "[OK] Linked: $Target" -ForegroundColor Green
        return $true
    }
    catch {
        if ($_.Exception.Message -match "require administrator") {
            # Remplacement de ✗ par [Error]
            Write-Host "[Error] Failed to create symlink (requires admin): $Target" -ForegroundColor Red
            Write-Host "  Run this script as Administrator to create symlinks." -ForegroundColor Red
            return $false
        }
        else {
            # Remplacement de ✗ par [Error]
            Write-Host "[Error] Failed to create symlink: $_" -ForegroundColor Red
            return $false
        }
    }
}

# Shell configurations
Create-SymlinkSafely "$DOTFILES\shell\bashrc" "$env:USERPROFILE\.bashrc"
Create-SymlinkSafely "$DOTFILES\shell\zshrc" "$env:USERPROFILE\.zshrc"

# Git configuration
Create-SymlinkSafely "$DOTFILES\git\gitconfig" "$env:USERPROFILE\.gitconfig"

# Vim configurations
Create-SymlinkSafely "$DOTFILES\vim\vimrc" "$env:USERPROFILE\.vimrc"
Create-SymlinkSafely "$DOTFILES\vim\ideavimrc" "$env:USERPROFILE\.ideavimrc"

# Tmux configuration
Create-SymlinkSafely "$DOTFILES\tmux\tmux.conf" "$env:USERPROFILE\.tmux.conf"

# Neovim configuration
$nvimDir = "$env:USERPROFILE\AppData\Local\nvim"
if (-not (Test-Path $nvimDir)) {
    New-Item -ItemType Directory -Path $nvimDir -Force | Out-Null
}
Create-SymlinkSafely "$DOTFILES\nvim\init.vim" "$nvimDir\init.vim"

Write-Host ""
# Remplacement de ✓ par [OK]
Write-Host "[OK] Dotfiles installation complete." -ForegroundColor Green
Write-Host ""

if (-not $isAdmin) {
    Write-Host "NOTE: Some symlinks may have failed due to lack of admin privileges." -ForegroundColor Yellow
    Write-Host "For full functionality, run this script as Administrator:" -ForegroundColor Yellow
    Write-Host "  powershell -RunAs Administrator -File scripts\symlink.ps1" -ForegroundColor Yellow
}