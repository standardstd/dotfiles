#!/usr/bin/env bash
set -euo pipefail

# --- Détection de la racine des Dotfiles ---
# Si $DOTFILES n'est pas défini, on calcule par rapport à l'emplacement du script
# Le script est dans scripts/, donc on remonte d'un niveau
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Source du script de détection d'OS
if [ -f "$DOTFILES/scripts/os.sh" ]; then
    source "$DOTFILES/scripts/os.sh"
    OS=$(detect_os)
else
    # Fallback si os.sh est introuvable
    OS="linux"
    [[ "$OSTYPE" == "darwin"* ]] && OS="mac"
    [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]] && OS="windows"
fi

echo "--- Installing base tools for: $OS ---"

if [ "$OS" = "linux" ]; then
    echo "Detected Linux distribution (WSL/Native)"
    
    # --- Debian / Ubuntu (apt) ---
    if command -v apt-get &> /dev/null; then
        # Dépendances pyenv + outils de base
        PYENV_DEPS=(make build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
        xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev)
        
        PACKAGES=(git zsh tmux neovim curl ripgrep fd-find)
        
        echo "Updating apt and installing packages..."
        sudo apt-get update
        sudo apt-get install -y "${PACKAGES[@]}" "${PYENV_DEPS[@]}"
        
        # Lien symbolique pour fd (souvent nommé fdfind sur Ubuntu)
        mkdir -p "$HOME/.local/bin"
        if command -v fdfind &> /dev/null && [ ! -f "$HOME/.local/bin/fd" ]; then
            ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
            echo "[OK] Linked fdfind to $HOME/.local/bin/fd"
        fi

    # --- Fedora (dnf) ---
    elif command -v dnf &> /dev/null; then
        PACKAGES=(git zsh tmux neovim curl ripgrep fd-find)
        sudo dnf install -y "${PACKAGES[@]}"

    # --- Arch Linux (pacman) ---
    elif command -v pacman &> /dev/null; then
        PACKAGES=(git zsh tmux neovim curl ripgrep fd)
        sudo pacman -S --noconfirm "${PACKAGES[@]}"
    fi

    # Installation de pyenv (seulement si manquant)
    if [ ! -d "$HOME/.pyenv" ]; then
        echo "Installing pyenv..."
        curl https://pyenv.run | bash
    else
        echo "[SKIP] pyenv already installed"
    fi

elif [ "$OS" = "mac" ]; then
    echo "Detected macOS"
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Configuration immédiate du path pour brew sur Apple Silicon
        [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    PACKAGES=(git zsh tmux neovim ripgrep fd pyenv)
    brew install "${PACKAGES[@]}"

elif [ "$OS" = "windows" ]; then
    # On appelle ton script PowerShell que nous avons déjà corrigé
    powershell.exe -ExecutionPolicy Bypass -File "$DOTFILES/scripts/install-tools.ps1"
fi

echo "--- Tools installation complete ---"