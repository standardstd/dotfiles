#!/usr/bin/env bash

source ./scripts/os.sh

OS=$(detect_os)

echo "--- Installing base tools for: $OS ---"

if [ "$OS" = "linux" ]; then
    PACKAGES=(git zsh tmux neovim curl ripgrep fd-find)
    sudo apt update
    sudo apt install -y "${PACKAGES[@]}"
    
    mkdir -p ~/.local/bin
    ln -sf $(which fdfind) ~/.local/bin/fd

elif [ "$OS" = "mac" ]; then
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    PACKAGES=(git zsh tmux neovim ripgrep fd)
    brew install "${PACKAGES[@]}"

elif [ "$OS" = "windows" ]; then
    if ! command -v winget &> /dev/null; then
        echo "Winget not found. Please install it from the Microsoft Store."
    else
        PACKAGES=(Git.Git Neovim.Neovim Microsoft.VisualStudioCode)
        for package in "${PACKAGES[@]}"; do
            winget install --exact --id "$package" --silent --accept-source-agreements --accept-package-agreements
        done
    fi
fi

echo "--- Tools installation complete ---"