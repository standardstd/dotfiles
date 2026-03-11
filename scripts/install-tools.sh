#!/usr/bin/env bash
set -euo pipefail

# Le script hérite de $DOTFILES s'il est appelé via 'source'
# Sinon, on le calcule
DOTFILES="${DOTFILES:-$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )")}"

# Source the OS detection script
source "$DOTFILES/scripts/os.sh"
OS=$(detect_os)

echo "--- Installing base tools for: $OS ---"

if [ "$OS" = "linux" ]; then
    echo "Detected Linux distribution"
    
    # --- Debian / Ubuntu (apt) ---
    if command -v apt-get &> /dev/null; then
        PACKAGES=(git zsh tmux neovim curl ripgrep fd-find)
        echo "Using apt-get to install packages..."
        sudo apt update
        sudo apt install -y "${PACKAGES[@]}"
        
        # Correction pour fd-find (nom spécifique à Ubuntu)
        mkdir -p "$HOME/.local/bin"
        if command -v fdfind &> /dev/null; then
            ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
            echo "✓ Linked fdfind to $HOME/.local/bin/fd"
            
            # Alerte si .local/bin n'est pas dans le PATH
            if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                echo "⚠ Warning: Please add \$HOME/.local/bin to your PATH in your .zshrc/.bashrc"
            fi
        fi

    # --- Fedora (dnf) ---
    elif command -v dnf &> /dev/null; then
        PACKAGES=(git zsh tmux neovim curl ripgrep fd-find)
        echo "Using dnf to install packages..."
        sudo dnf install -y "${PACKAGES[@]}"

    # --- Arch Linux (pacman) ---
    elif command -v pacman &> /dev/null; then
        PACKAGES=(git zsh tmux neovim curl ripgrep fd)
        echo "Using pacman to install packages..."
        sudo pacman -S --noconfirm "${PACKAGES[@]}"

    else
        echo "⚠ Unknown package manager. Please install: git, zsh, tmux, neovim, curl, ripgrep, fd"
    fi

elif [ "$OS" = "mac" ]; then
    echo "Detected macOS"
    
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Ajout au PATH immédiat pour la session actuelle (Apple Silicon)
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
    
    PACKAGES=(git zsh tmux neovim ripgrep fd)
    echo "Using Homebrew to install packages..."
    brew install "${PACKAGES[@]}"

elif [ "$OS" = "windows" ]; then
    # Comme bootstrap.sh redirige déjà vers .ps1, ce bloc devient une sécurité
    echo "Running Windows-specific setup via PowerShell..."
    powershell.exe -ExecutionPolicy Bypass -File "$DOTFILES/bootstrap.ps1"
    
else
    echo "ERROR: Unknown or unsupported OS: $OS"
    exit 1
fi

echo "--- Tools installation complete ---"