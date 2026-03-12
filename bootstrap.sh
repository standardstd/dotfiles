#!/usr/bin/env bash
set -euo pipefail

# --- Détection de la racine des Dotfiles ---
# Comme ce script est dans scripts/, on remonte d'un niveau
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTFILES="$(dirname "$SCRIPT_DIR")"

echo "--- Starting Dotfiles Bootstrap from: $DOTFILES ---"
echo ""

# --- Détection de l'OS via le script centralisé ---
if [[ -f "$DOTFILES/scripts/os.sh" ]]; then
    source "$DOTFILES/scripts/os.sh"
    OS=$(detect_os)
else
    # Fallback si os.sh est absent
    OS="linux"
    [[ "$OSTYPE" == "darwin"* ]] && OS="mac"
    [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]] && OS="windows"
fi

echo "Detected OS: $OS"
echo ""

# 1. Run installation scripts (Tools + Pyenv)
echo "--- Step 1: Installing tools ---"
if [ "$OS" = "windows" ]; then
    echo "Running Windows tools installation via PowerShell..."
    powershell.exe -ExecutionPolicy Bypass -File "$DOTFILES/scripts/install-tools.ps1"
else
    bash "$DOTFILES/scripts/install-tools.sh"
fi
echo ""

# 2. Setup Symlinks
echo "--- Step 2: Creating symlinks ---"
if [ "$OS" = "windows" ]; then
    # Sous Windows (même via Git Bash), on préfère le script PS1 pour les privilèges admin/mode dev
    powershell.exe -ExecutionPolicy Bypass -File "$DOTFILES/scripts/symlink.ps1"
else
    bash "$DOTFILES/scripts/symlink.sh"
fi
echo ""

# 3. VS Code Extensions (with safety guard)
echo "--- Step 3: Installing VS Code extensions ---"
if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
    echo ">>> Skipping VS Code extensions installation (already inside VS Code terminal)."
else
    if [ "$OS" = "windows" ]; then
        powershell.exe -ExecutionPolicy Bypass -File "$DOTFILES/scripts/install-vscode-extensions.ps1"
    else
        # Si tu as un script .sh pour les extensions VS Code (mac/linux)
        if [[ -f "$DOTFILES/scripts/install-vscode-extensions.sh" ]]; then
            bash "$DOTFILES/scripts/install-vscode-extensions.sh"
        fi
    fi
fi
echo ""

echo "==========================================="
echo "[OK] Setup complete!"
echo "==========================================="
echo "Please restart your terminal or run:"
echo "source ~/.zshrc (or ~/.bashrc)"