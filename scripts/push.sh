#!/usr/bin/env bash
set -euo pipefail

# Répertoire racine
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$DOTFILES"

echo "--- Pushing Dotfiles to GitHub ---"

# 1. Préparation des changements
git add .

# 2. Vérification de sécurité (Pre-commit)
echo "Running security checks..."
if [[ -f "$DOTFILES/scripts/check-secrets.sh" ]]; then
    if ! bash "$DOTFILES/scripts/check-secrets.sh"; then
        echo "❌ Push aborted due to security risks."
        exit 1
    fi
else
    echo "⚠️  Warning: scripts/check-secrets.sh not found, skipping security check."
fi

# 3. Message de commit
echo -n "Commit message (Enter for 'Daily dotfiles update'): "
read -r msg

if [ -z "$msg" ]; then
    msg="Daily dotfiles update ($(date +'%Y-%m-%d %H:%M'))"
fi

# 4. Sync
echo "Syncing with GitHub..."
git commit -m "$msg"
git push

echo "-------------------------------------------"
echo "✓ Changes pushed successfully!"