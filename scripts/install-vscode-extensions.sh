#!/usr/bin/env bash
set -euo pipefail

# Utilise $DOTFILES si défini, sinon calcule le parent
DOTFILES="${DOTFILES:-$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )")}"

# Vérification de la commande 'code'
if ! command -v code &> /dev/null; then
    echo "-------------------------------------------------------"
    echo "WARNING: VS Code CLI (code) not found."
    
    # Aide spécifique pour macOS
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "Tip: Open VS Code, press Cmd+Shift+P, and search for:"
        echo "     'Shell Command: Install 'code' command in PATH'"
    fi
    
    echo "Skipping extension installation for now."
    echo "-------------------------------------------------------"
    exit 0
fi

EXT_FILE="$DOTFILES/vscode/extensions.txt"

if [ -f "$EXT_FILE" ]; then
    echo "Installing VS Code extensions from: $EXT_FILE"
    
    # Lecture ligne par ligne
    while IFS= read -r extension || [[ -n "$extension" ]]; do
        # On ignore les lignes vides et les commentaires (#)
        [[ -z "$extension" || "$extension" =~ ^# ]] && continue
        
        # Nettoyage des caractères invisibles (cas où le fichier vient de Windows)
        extension=$(echo "$extension" | tr -d '\r' | xargs)
        
        echo "Installing: $extension"
        # --force évite de redemander si déjà installé
        if code --install-extension "$extension" --force > /dev/null 2>&1; then
            echo "  ✓ $extension"
        else
            echo "  ⚠ Failed: $extension"
        fi
    done < "$EXT_FILE"
    
    echo "✓ Extensions installation complete."
else
    echo "ERROR: $EXT_FILE not found"
    exit 1
fi