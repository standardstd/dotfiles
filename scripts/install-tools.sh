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
        # Ajout des dépendances de compilation pour Python (pyenv)
        PYENV_DEPS=(make build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
        xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev)
        
        PACKAGES=(git zsh tmux neovim curl ripgrep fd-find)
        echo "Using apt-get to install packages and pyenv dependencies..."
        sudo apt update
        sudo apt install -y "${PACKAGES[@]}" "${PYENV_DEPS[@]}"
        
        # Correction pour fd-find
        mkdir -p "$HOME/.local/bin"
        if command -v fdfind &> /dev/null; then
            ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
            echo "[OK] Linked fdfind to $HOME/.local/bin/fd"
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
    fi

    # Installation de pyenv
    if [ ! -d "$HOME/.pyenv" ]; then
        echo "Installing pyenv..."
        curl https://pyenv.run | bash
    fi

elif [ "$OS" = "mac" ]; then
    echo "Detected macOS"
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -f /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
    fi
    PACKAGES=(git zsh tmux neovim ripgrep fd pyenv)
    brew install "${PACKAGES[@]}"

elif [ "$OS" = "windows" ]; then
    powershell.exe -ExecutionPolicy Bypass -File "$DOTFILES/scripts/install-tools.ps1"
fi

echo "--- Tools installation complete ---"