#!/usr/bin/env bash
set -euo pipefail

# --- Détection du répertoire racine (Standardisé) ---
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

echo "--- Installing dotfiles from: $DOTFILES ---"

# Fonction pour créer un lien symbolique proprement
create_symlink() {
    local src="$1"
    local dst="$2"
    
    if [ ! -e "$src" ]; then
        echo "⚠ Source not found: $src"
        return 0
    fi
    
    # S'assurer que le dossier parent de la destination existe
    mkdir -p "$(dirname "$dst")"
    
    # Gestion de l'existant
    if [ -L "$dst" ]; then
        # C'est déjà un lien, on le supprime pour le mettre à jour
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        # C'est un vrai fichier, on fait un backup
        local backup="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  Backing up existing file to: $backup"
        mv "$dst" "$backup"
    fi
    
    ln -sf "$src" "$dst"
    echo "✓ Linked: $dst"
}

# --- 1. Shell configurations ---
create_symlink "$DOTFILES/shell/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES/shell/bashrc" "$HOME/.bashrc"

# --- 2. Git configuration ---
create_symlink "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"

# --- 3. Vim & IDE configurations ---
create_symlink "$DOTFILES/vim/vimrc" "$HOME/.vimrc"
create_symlink "$DOTFILES/vim/ideavimrc" "$HOME/.ideavimrc"

# --- 4. Tmux configuration ---
create_symlink "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

# --- 5. Neovim configuration ---
# On lie tout le dossier de config pour que Lua/plugins fonctionnent
create_symlink "$DOTFILES/nvim" "$HOME/.config/nvim"

# --- 6. VS Code configuration (Linux & macOS) ---
VSCODE_SETTING_DIR=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Cas du WSL ou Linux natif
    VSCODE_SETTING_DIR="$HOME/.config/Code/User"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Cas de macOS
    VSCODE_SETTING_DIR="$HOME/Library/Application Support/Code/User"
fi

if [ -n "$VSCODE_SETTING_DIR" ]; then
    create_symlink "$DOTFILES/vscode/settings.json" "$VSCODE_SETTING_DIR/settings.json"
    create_symlink "$DOTFILES/vscode/keybindings.json" "$VSCODE_SETTING_DIR/keybindings.json"
fi

echo "-------------------------------------------"
echo "✓ Dotfiles installation complete."