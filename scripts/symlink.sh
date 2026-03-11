#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES="$(dirname "$SCRIPT_DIR")"

echo "Installing dotfiles from: $DOTFILES"

# Function to create symlink safely
create_symlink() {
    local src="$1"
    local dst="$2"
    
    if [ ! -e "$src" ]; then
        echo "⚠ Source not found: $src"
        return 1
    fi
    
    # Backup existing file if it exists and is not a symlink
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ -L "$dst" ]; then
            echo "  Replacing existing symlink: $dst"
            rm -f "$dst"
        else
            BACKUP="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
            echo "  Backing up existing file to: $BACKUP"
            mv "$dst" "$BACKUP"
        fi
    fi
    
    ln -sf "$src" "$dst"
    echo "✓ Linked: $dst"
}

# Shell configurations
create_symlink "$DOTFILES/shell/zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES/shell/bashrc" "$HOME/.bashrc"

# Git configuration
create_symlink "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"

# Vim configurations
create_symlink "$DOTFILES/vim/vimrc" "$HOME/.vimrc"
create_symlink "$DOTFILES/vim/ideavimrc" "$HOME/.ideavimrc"

# Tmux configuration
create_symlink "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

# Neovim configuration
mkdir -p "$HOME/.config/nvim"
create_symlink "$DOTFILES/nvim/init.vim" "$HOME/.config/nvim/init.vim"

echo "✓ Dotfiles installation complete."