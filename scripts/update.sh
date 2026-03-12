#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "⚠️  Running in DRY-RUN mode. No changes will be applied."
fi

run() {
    if $DRY_RUN; then
        echo "[DRY-RUN] $*"
    else
        # Utilisation de "$@" au lieu de eval pour plus de sécurité avec les arguments
        "$@"
    fi
}

# 1. Répertoire racine (Standardisé)
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# 2. Charger la détection d'OS
if [[ -f "$DOTFILES/scripts/os.sh" ]]; then
    source "$DOTFILES/scripts/os.sh"
    OS=$(detect_os)
else
    # Fallback basique
    [[ "$OSTYPE" == "darwin"* ]] && OS="mac" || OS="linux"
fi

echo "--- Updating Dotfiles ($OS) ---"

# 3. Git Pull (Sync config)
echo "Pulling latest changes from Git..."
# -C permet d'exécuter git dans le dossier spécifié
run git -C "$DOTFILES" pull --rebase --autostash

# 4. Mise à jour des paquets système
echo "Updating system packages..."
case "$OS" in
    linux)
        if command -v apt-get &>/dev/null; then
            run sudo apt-get update
            run sudo apt-get upgrade -y
            run sudo apt-get autoremove -y
        elif command -v pacman &>/dev/null; then
            run sudo pacman -Syu --noconfirm
        elif command -v dnf &>/dev/null; then
            run sudo dnf upgrade -y
        fi
        ;;
    mac)
        if command -v brew &>/dev/null; then
            run brew update
            run brew upgrade
            run brew cleanup
        fi
        ;;
    windows)
        # Optionnel : On pourrait appeler winget upgrade --all ici
        echo "Windows detected. Use 'winget upgrade --all' in PowerShell for tools."
        ;;
esac

# 5. Refresh Symlinks
echo "Refreshing symlinks..."
if [[ -f "$DOTFILES/scripts/symlink.sh" ]]; then
    if $DRY_RUN; then
        echo "[DRY-RUN] Would run: $DOTFILES/scripts/symlink.sh"
    else
        # On l'exécute dans le shell actuel pour hériter des variables si besoin
        bash "$DOTFILES/scripts/symlink.sh"
    fi
else
    echo "❌ scripts/symlink.sh not found!"
fi

echo "-------------------------------------------"
echo "✓ Update complete!"