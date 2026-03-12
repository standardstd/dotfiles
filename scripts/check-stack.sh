#!/bin/bash

# Couleurs pour la lisibilité
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== 🛡️  Vérification de la Stack Ugram (WSL) ===${NC}\n"

# 1. Check Java & Maven
echo -n "☕ Java: "
if command -v java >/dev/null; then
    # Extraction propre de la version
    JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo -e "${GREEN}v$JAVA_VER${NC}"
else
    echo -e "${RED}MANQUANT (Vérifiez votre PATH WSL)${NC}"
fi

echo -n "🏗️  Maven: "
if command -v mvn >/dev/null; then
    MVN_VER=$(mvn -v | head -n 1 | cut -d' ' -f3)
    echo -e "${GREEN}v$MVN_VER${NC}"
else
    echo -e "${RED}MANQUANT${NC}"
fi

# 2. Check Docker
echo -n "🐳 Docker Engine: "
if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}En cours d'exécution${NC}"
else
    echo -e "${RED}ARRÊTÉ (Lancez Docker Desktop sur Windows)${NC}"
fi

# 3. Check Containers & Health
echo -e "\n${BLUE}📋 État des services Docker (Ugram):${NC}"
# On cherche les containers qui contiennent "ugram" dans leur nom
UGRAM_CONTAINERS=$(docker ps -a --format "{{.Names}}" | grep "ugram")

if [ -n "$UGRAM_CONTAINERS" ]; then
    # Affichage propre avec formatage table
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "Names|ugram"
else
    echo -e "${YELLOW}Aucun container 'ugram' trouvé. Lancez 'dcub' dans PowerShell.${NC}"
fi

# 4. Check Database Port (PostgreSQL)
# Note: localhost dans WSL2 pointe vers l'IP de Windows si Docker Desktop est utilisé
echo -ne "\n🐘 Port PostgreSQL (5432): "
if nc -z -w 1 localhost 5432 >/dev/null 2>&1; then
    echo -e "${GREEN}OUVERT (Prêt)${NC}"
else
    echo -e "${RED}FERMÉ (Vérifiez le container de la base de données)${NC}"
fi

echo -e "\n${BLUE}======================================${NC}"