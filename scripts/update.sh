#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

run() {
    if $DRY_RUN; then
        echo "[DRY-RUN] $*"
    else
        eval "$@"
    fi
}

# Répertoire racine
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Charger la détection d'OS
if [[ -f "$DOTFILES/scripts/os.sh" ]]; then
    source "$DOTFILES/scripts/os.sh"
    OS=$(detect_os)
else
    OS="unknown"
fi

echo "--- Updating Dotfiles ($OS) ---"

# 1. Git Pull
echo "Pulling latest changes from Git..."
run git -C "$DOTFILES" pull --rebase --autostash

# 2. Mise à jour des paquets
echo "Updating system packages..."
case "$OS" in
    linux)
        if command -v apt-get &>/dev/null; then
            run "sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"
        elif command -v pacman &>/dev/null; then
            run "sudo pacman -Syu --noconfirm"
        elif command -v dnf &>/dev/null; then
            run "sudo dnf upgrade -y"
        fi
        ;;
    mac)
        if command -v brew &>/dev/null; then
            run "brew update && brew upgrade && brew cleanup"
        fi
        ;;
esac

# 3. Symlinks
echo "Refreshing symlinks..."
if [[ -f "$DOTFILES/scripts/symlink.sh" ]]; then
    if $DRY_RUN; then
        echo "[DRY-RUN] Would run: $DOTFILES/scripts/symlink.sh"
    else
        source "$DOTFILES/scripts/symlink.sh"
    fi
else
    echo "❌ scripts/symlink.sh not found!"
fi

echo "-------------------------------------------"
echo "✓ Update complete!"