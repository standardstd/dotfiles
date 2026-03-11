#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES="$(dirname "$SCRIPT_DIR")"

# Source the OS detection script
source "$DOTFILES/scripts/os.sh"

OS=$(detect_os)

echo "--- Installing base tools for: $OS ---"

if [ "$OS" = "linux" ]; then
    echo "Detected Linux distribution"
    
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        PACKAGES=(git zsh tmux neovim curl ripgrep fd-find)
        echo "Using apt-get to install packages..."
        sudo apt update
        sudo apt install -y "${PACKAGES[@]}"
        
        # Create symlink for fd-find (different name on Ubuntu)
        mkdir -p ~/.local/bin
        if ! ln -sf "$(which fdfind)" ~/.local/bin/fd 2>/dev/null; then
            echo "⚠ Note: fd symlink in ~/.local/bin may not work. fd-find is available as 'fdfind'"
        fi
    elif command -v dnf &> /dev/null; then
        PACKAGES=(git zsh tmux neovim curl ripgrep fd)
        echo "Using dnf to install packages..."
        sudo dnf install -y "${PACKAGES[@]}"
    elif command -v pacman &> /dev/null; then
        PACKAGES=(git zsh tmux neovim curl ripgrep fd)
        echo "Using pacman to install packages..."
        sudo pacman -S --noconfirm "${PACKAGES[@]}"
    else
        echo "⚠ Unknown package manager. Please install tools manually:"
        echo "  git, zsh, tmux, neovim, curl, ripgrep, fd"
    fi

elif [ "$OS" = "mac" ]; then
    echo "Detected macOS"
    
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    PACKAGES=(git zsh tmux neovim ripgrep fd)
    echo "Using Homebrew to install packages..."
    brew install "${PACKAGES[@]}"

elif [ "$OS" = "windows" ]; then
    echo "Detected Windows (running under WSL or Git Bash)"
    echo "For Windows native development, use: powershell -ExecutionPolicy Bypass -File bootstrap.ps1"
    echo ""
    echo "Note: On WSL, you may want to run the Linux installation instead."
    
else
    echo "ERROR: Unknown or unsupported OS: $OS"
    exit 1
fi

echo "--- Tools installation complete ---"