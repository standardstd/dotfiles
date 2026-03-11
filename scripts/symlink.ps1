# symlink.ps1 - Create symlinks for dotfiles on Windows
# Usage: Appelé par bootstrap.ps1 ou lancé directement

$ErrorActionPreference = "Stop"

# --- Définition des chemins dynamiques ---
# On récupère la racine du projet à partir de l'emplacement du script
$SCRIPT_DIR = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$DOTFILES = Split-Path -Parent -Path $SCRIPT_DIR

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
    
    # Ensure target parent directory exists
    $targetParent = Split-Path -Parent $Target
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }
    
    # Backup existing file if it exists and is not a symlink
    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        # Vérifie si c'est déjà un lien (ReparsePoint)
        if ($item.Attributes -match "ReparsePoint" -or $item.LinkType -eq "SymbolicLink") {
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
    
    # Create symlink
    try {
        # Utilisation de New-Item pour créer le lien symbolique
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

# --- 2. PowerShell Profile ---
# On lie le profil Windows vers le fichier dans ton repo dotfiles
Create-SymlinkSafely "$DOTFILES\shell\Microsoft.PowerShell_profile.ps1" "$PROFILE"

# --- 3. Git configuration ---
Create-SymlinkSafely "$DOTFILES\git\gitconfig" "$env:USERPROFILE\.gitconfig"

# --- 4. Vim & IDE configurations ---
Create-SymlinkSafely "$DOTFILES\vim\vimrc" "$env:USERPROFILE\.vimrc"
Create-SymlinkSafely "$DOTFILES\vim\ideavimrc" "$env:USERPROFILE\.ideavimrc"

# --- 5. Tmux configuration ---
Create-SymlinkSafely "$DOTFILES\tmux\tmux.conf" "$env:USERPROFILE\.tmux.conf"

# --- 6. Neovim configuration ---
$nvimDir = "$env:USERPROFILE\AppData\Local\nvim"
Create-SymlinkSafely "$DOTFILES\nvim\init.vim" "$nvimDir\init.vim"

# --- 7. VS Code configuration ---
$vscodeDir = "$env:APPDATA\Code\User"
Create-SymlinkSafely "$DOTFILES\vscode\settings.json" "$vscodeDir\settings.json"
Create-SymlinkSafely "$DOTFILES\vscode\keybindings.json" "$vscodeDir\keybindings.json"

Write-Host ""
Write-Host "[OK] Dotfiles installation complete." -ForegroundColor Green
Write-Host ""

if (-not $isAdmin) {
    Write-Host "Note: If any symlinks failed, double-check that 'Developer Mode' is ON in Windows Settings." -ForegroundColor Yellow
}