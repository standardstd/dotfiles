# symlink.ps1 - Create symlinks for dotfiles on Windows
$ErrorActionPreference = "Stop"

# --- Définition des chemins ---
# Utilise la variable d'environnement ou le chemin standard
$DOTFILES = $env:DOTFILES
if (-not $DOTFILES) { $DOTFILES = "$HOME\dotfiles" }

Write-Host "--- Installing dotfiles from: $DOTFILES ---" -ForegroundColor Green
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "INFO: Not running as Administrator." -ForegroundColor Cyan
    Write-Host "Symlinks will work if 'Developer Mode' is enabled in Windows Settings." -ForegroundColor Cyan
    Write-Host ""
}

# --- Fonction de création sécurisée ---
function Create-SymlinkSafely {
    param(
        [string]$Source,
        [string]$Target
    )
    
    if (-not (Test-Path $Source)) {
        Write-Host "[!] Source not found (skipping): $Source" -ForegroundColor Yellow
        return
    }
    
    $targetParent = Split-Path -Parent $Target
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }
    
    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.Attributes -match "ReparsePoint" -or $item.LinkType) {
            Write-Host "  Replacing existing symlink: $Target" -ForegroundColor Gray
            Remove-Item $Target -Force
        }
        else {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backup = "$Target.backup.$timestamp"
            Write-Host "  Backing up existing file to: $backup" -ForegroundColor Yellow
            Move-Item $Target $backup -Force
        }
    }
    
    try {
        New-Item -ItemType SymbolicLink -Path $Target -Value $Source -Force -ErrorAction Stop | Out-Null
        Write-Host "[OK] Linked: $Target" -ForegroundColor Green
    }
    catch {
        Write-Host "[Error] Failed to create symlink for: $Target" -ForegroundColor Red
        Write-Host "Reason: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- 1. Shell configurations ---
Create-SymlinkSafely "$DOTFILES\shell\bashrc" "$env:USERPROFILE\.bashrc"
Create-SymlinkSafely "$DOTFILES\shell\zshrc" "$env:USERPROFILE\.zshrc"

# --- 2. PowerShell Profiles (Double Liaison V5 et V7) ---
$sourceProfile = "$DOTFILES\shell\Microsoft.PowerShell_profile.ps1"

# Lien pour Windows PowerShell (v5.1 - La console bleue)
Create-SymlinkSafely $sourceProfile "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Create-SymlinkSafely $sourceProfile "$HOME\Documents\WindowsPowerShell\Microsoft.VSCode_profile.ps1"

# Lien pour PowerShell Core (v7+ - Ta nouvelle console par défaut)
Create-SymlinkSafely $sourceProfile "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Create-SymlinkSafely $sourceProfile "$HOME\Documents\PowerShell\Microsoft.VSCode_profile.ps1"

# --- 3. Git configuration ---
Create-SymlinkSafely "$DOTFILES\git\gitconfig" "$env:USERPROFILE\.gitconfig"

# --- 4. Vim & IDE configurations ---
Create-SymlinkSafely "$DOTFILES\vim\vimrc" "$env:USERPROFILE\.vimrc"
Create-SymlinkSafely "$DOTFILES\vim\ideavimrc" "$env:USERPROFILE\.ideavimrc"

# --- 5. Tmux configuration ---
Create-SymlinkSafely "$DOTFILES\tmux\tmux.conf" "$env:USERPROFILE\.tmux.conf"

# --- 6. Neovim configuration ---
$nvimDir = "$env:LOCALAPPDATA\nvim"
Create-SymlinkSafely "$DOTFILES\nvim" "$nvimDir" # On lie tout le dossier pour Neovim

# --- 7. VS Code configuration ---
$vscodeDir = "$env:APPDATA\Code\User"
Create-SymlinkSafely "$DOTFILES\vscode\settings.json" "$vscodeDir\settings.json"
Create-SymlinkSafely "$DOTFILES\vscode\keybindings.json" "$vscodeDir\keybindings.json"

Write-Host ""
Write-Host "[OK] Dotfiles installation complete." -ForegroundColor Green