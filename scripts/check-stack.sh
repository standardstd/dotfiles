#!/bin/bash

# Couleurs pour la lisibilité
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== 🛡️ Verification de la Stack Ugram ===${NC}\n"

# 1. Check Java & Maven
echo -n "☕ Java: "
if command -v java >/dev/null; then
    echo -e "${GREEN}$(java -version 2>&1 | head -n 1)${NC}"
else
    echo -e "${RED}MANQUANT${NC}"
fi

echo -n "🏗️  Maven: "
if command -v mvn >/dev/null; then
    echo -e "${GREEN}Installé${NC}"
else
    echo -e "${RED}MANQUANT${NC}"
fi

# 2. Check Docker
echo -n "🐳 Docker Engine: "
if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}En cours d'exécution${NC}"
else
    echo -e "${RED}ARRÊTÉ (Lancez Docker Desktop)${NC}"
fi

# 3. Check Containers & Health
echo -e "\n${BLUE}📋 État des services Docker:${NC}"
if docker ps -a | grep -q "ugram"; then
    docker ps --format "table {{.Names}}\t{{.Status}}" | grep "ugram"
else
    echo -e "${RED}Aucun container 'ugram' trouvé. Lancez 'dcub'.${NC}"
fi

# 4. Check Database Port (PostgreSQL default)
echo -ne "\n🐘 Port PostgreSQL (5432): "
if nc -z localhost 5432 2>/dev/null; then
    echo -e "${GREEN}OUVERT (Prêt)${NC}"
else
    echo -e "${RED}FERMÉ (Vérifiez le container DB)${NC}"
fi

echo -e "\n${BLUE}======================================${NC}"