#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES="$(dirname "$SCRIPT_DIR")"

if ! command -v code &> /dev/null; then
    echo "WARNING: VS Code CLI (code) not found. Skipping extension installation."
    echo "Make sure VS Code is installed and the 'code' command is available in PATH."
    exit 0
fi

echo "Installing VSCode extensions..."

if [ -f "$DOTFILES/vscode/extensions.txt" ]; then
    while IFS= read -r extension; do
        # Skip empty lines and comments
        [[ -z "$extension" || "$extension" =~ ^# ]] && continue
        
        echo "Installing: $extension"
        if code --install-extension "$extension" --force; then
            echo "✓ Installed $extension"
        else
            echo "⚠ Failed to install $extension"
        fi
    done < "$DOTFILES/vscode/extensions.txt"
    
    echo "✓ Extensions installation complete."
else
    echo "ERROR: $DOTFILES/vscode/extensions.txt not found"
    exit 1
fi