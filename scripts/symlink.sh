#!/usr/bin/env bash
set -euo pipefail

# Utilise $DOTFILES si défini par le bootstrap, sinon calcule le parent
DOTFILES="${DOTFILES:-$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )")}"

echo "Installing dotfiles from: $DOTFILES"

# Fonction pour créer un lien symbolique proprement
create_symlink() {
    local src="$1"
    local dst="$2"
    
    if [ ! -e "$src" ]; then
        echo "⚠ Source not found: $src"
        return 0 # On ne quitte pas le script, on passe au suivant
    fi
    
    # S'assurer que le dossier parent de la destination existe
    mkdir -p "$(dirname "$dst")"
    
    # Backup si c'est un vrai fichier/dossier, suppression si c'est déjà un lien
    if [ -L "$dst" ]; then
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        local backup="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  Backing up existing file to: $backup"
        mv "$dst" "$backup"
    fi
    
    ln -sf "$src" "$dst"
    echo "✓ Linked: $dst"
}

# --- Shell configurations ---
create_symlink "$DOTFILES/shell/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES/shell/bashrc" "$HOME/.bashrc"

# --- Git configuration ---
create_symlink "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"

# --- Vim & IDE configurations ---
create_symlink "$DOTFILES/vim/vimrc" "$HOME/.vimrc"
create_symlink "$DOTFILES/vim/ideavimrc" "$HOME/.ideavimrc"

# --- Tmux configuration ---
create_symlink "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

# --- Neovim configuration ---
# (mkdir -p est maintenant géré à l'intérieur de create_symlink)
create_symlink "$DOTFILES/nvim/init.vim" "$HOME/.config/nvim/init.vim"

# --- VS Code configuration (Linux & macOS) ---
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    VSCODE_SETTING_DIR="$HOME/.config/Code/User"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    VSCODE_SETTING_DIR="$HOME/Library/Application Support/Code/User"
fi

if [ -n "${VSCODE_SETTING_DIR:-}" ]; then
    create_symlink "$DOTFILES/vscode/settings.json" "$VSCODE_SETTING_DIR/settings.json"
    create_symlink "$DOTFILES/vscode/keybindings.json" "$VSCODE_SETTING_DIR/keybindings.json"
fi

echo "✓ Dotfiles installation complete."