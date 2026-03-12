#!/usr/bin/env bash
# On garde le mode strict, c'est une excellente pratique
set -euo pipefail

echo "--- Running Security Pre-Check ---"

# Liste des motifs interdits (Regex)
FORBIDDEN_PATTERNS=(
    "BEGIN RSA PRIVATE KEY"
    "BEGIN OPENSSH PRIVATE KEY"
    "password ="
    "api_key ="
    "secret ="
)

# 1. Vérifier si des fichiers de backup sont indexés
# Le '|| true' est crucial ici pour ne pas arrêter le script si rien n'est trouvé
BACKUP_FILES=$(git diff --cached --name-only | grep -E "\.bak$|\.backup\..*" || true)
if [ -n "$BACKUP_FILES" ]; then
    echo "❌ ERROR: You are trying to commit backup files:"
    echo "$BACKUP_FILES"
    echo "Please remove them with: git reset HEAD <file>"
    exit 1
fi

# 2. Vérifier le contenu des fichiers indexés pour des secrets
for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    # '|| true' à la fin pour que le script continue si grep ne trouve rien
    # On utilise 'git diff --cached' pour ne scanner que ce qui va être commité
    FOUND_SECRET=$(git diff --cached | grep -v "scripts/check-secrets.sh" | grep -qi "$pattern" || true)
    
    # On teste si la commande grep a trouvé quelque chose sans laisser le pipefail tuer le script
    if git diff --cached | grep -v "scripts/check-secrets.sh" | grep -qi "$pattern"; then
        echo "❌ ERROR: Potential secret detected ('$pattern') in your staged changes!"
        echo "Please check your files before committing."
        exit 1
    fi
done

echo "✅ Security check passed."
exit 0