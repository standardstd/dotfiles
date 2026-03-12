#!/usr/bin/env bash
set -euo pipefail

# 1. Détection du répertoire racine (Standardisé)
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$DOTFILES"

echo "--- Pushing Dotfiles to GitHub ---"

# 2. Vérifier s'il y a des changements à commiter
if [[ -z $(git status --porcelain) ]]; then
    echo "✅ No changes to push. Everything is up to date."
    exit 0
fi

# 3. Préparation des changements
git add .

# 4. Vérification de sécurité (Pre-commit)
echo "Running security checks..."
if [[ -f "$DOTFILES/scripts/check-secrets.sh" ]]; then
    # On lance avec bash pour garantir la compatibilité
    if ! bash "$DOTFILES/scripts/check-secrets.sh"; then
        echo "❌ Push aborted due to security risks."
        exit 1
    fi
else
    echo "⚠️  Warning: scripts/check-secrets.sh not found, skipping security check."
fi

# 5. Message de commit
# Utilisation de 'read -p' pour une saisie plus propre
read -p "Commit message (Enter for 'Daily update'): " msg

if [ -z "$msg" ]; then
    msg="Daily dotfiles update ($(date +'%Y-%m-%d %H:%M'))"
fi

# 6. Sync
echo "Syncing with GitHub..."
if git commit -m "$msg" && git push; then
    echo "-------------------------------------------"
    echo "✓ Changes pushed successfully!"
else
    echo "❌ Error: Failed to push changes to GitHub."
    exit 1
fi