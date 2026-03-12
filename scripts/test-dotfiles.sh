#!/usr/bin/env bash
set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

echo -e "--- 🔍 Diagnostic des Dotfiles ($DOTFILES) ---\n"

# 1. Test des liens symboliques critiques
check_link() {
    local target="$1"
    echo -n "🔗 $target : "
    if [ -L "$target" ]; then
        if [ -e "$target" ]; then
            echo -e "${GREEN}[OK]${NC} (Pointe vers: $(readlink "$target"))"
        else
            echo -e "${RED}[BRISÉ]${NC} (La cible n'existe pas)"
        fi
    else
        echo -e "${RED}[PAS UN LIEN]${NC}"
    fi
}

echo "📂 Vérification des liens Shell & Git :"
check_link "$HOME/.bashrc"
check_link "$HOME/.zshrc"
check_link "$HOME/.gitconfig"
check_link "$HOME/.ideavimrc"

# 2. Vérification des Secrets
echo -e "\n🔐 Sécurité :"
if [ -f "$DOTFILES/secrets/private.sh" ]; then
    echo -e "✅ private.sh trouvé dans secrets/"
else
    echo -e "⚠️  private.sh manquant (Normal si c'est une nouvelle machine)"
fi

# 3. Test des commandes alias (Ugram Ready)
echo -e "\n🛠️  Disponibilité des outils :"
check_cmd() {
    if command -v "$1" &>/dev/null; then
        echo -e "✅ $1 : ${GREEN}Installé${NC}"
    else
        echo -e "❌ $1 : ${RED}Manquant${NC}"
    fi
}

check_cmd "mvn"
check_cmd "docker"
check_cmd "nvim"
check_cmd "pyenv"

echo -e "\n--- Fin du diagnostic ---"