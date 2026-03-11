#!/usr/bin/env bash

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTFILES="$SCRIPT_DIR"

echo "--- Starting Dotfiles Bootstrap from: $DOTFILES ---"
echo ""

# Detect OS
OS="unknown"
case "$(uname -s)" in
  Linux*)   OS="linux" ;;
  Darwin*)  OS="mac" ;;
  CYGWIN*|MINGW*|MSYS*) OS="windows" ;;
esac

echo "Detected OS: $OS"
echo ""

# 1. Run installation scripts (Tools + Pyenv)
if [ "$OS" = "windows" ]; then
    echo "Running Windows tools installation via PowerShell..."
    powershell.exe -ExecutionPolicy Bypass -File "$DOTFILES/scripts/install-tools.ps1"
else
    bash "$DOTFILES/scripts/install-tools.sh"
fi
echo ""

# 2. Setup Symlinks
bash "$DOTFILES/scripts/symlink.sh"
echo ""

# 3. VS Code Extensions (with safety guard)
if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
    echo ">>> Skipping VS Code extensions installation (already inside VS Code)."
else
    if [ "$OS" = "windows" ]; then
        powershell.exe -ExecutionPolicy Bypass -File "$DOTFILES/scripts/install-vscode-extensions.ps1"
    else
        bash "$DOTFILES/scripts/install-vscode-extensions.sh"
    fi
fi
echo ""

echo "[OK] Setup complete!"
echo "Please restart your terminal or run: source ~/.zshrc (or .bashrc)"