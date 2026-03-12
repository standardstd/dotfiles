#!/usr/bin/env bash

# Fonction simple pour retourner l'OS en minuscule
# Utilisée par install-tools.sh et update.sh
detect_os() {
    local os_name
    os_name="$(uname -s)"
    
    case "$os_name" in
        Linux*)               echo "linux" ;;
        Darwin*)              echo "mac" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)                    echo "unknown" ;;
    esac
}