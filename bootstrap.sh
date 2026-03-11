#!/usr/bin/env bash

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTFILES="$SCRIPT_DIR"

echo "Bootstrapping dev environment from: $DOTFILES"
echo ""

# Detect OS
OS="unknown"
case "$(uname -s)" in
  Linux*)  OS="linux" ;;
  Darwin*) OS="mac" ;;
  CYGWIN*|MINGW*|MSYS*) OS="windows" ;;
esac

echo "Detected OS: $OS"
echo ""

# Run installation scripts
bash "$DOTFILES/scripts/install-tools.sh"
echo ""

bash "$DOTFILES/scripts/symlink.sh"
echo ""

bash "$DOTFILES/scripts/install-vscode-extensions.sh"
echo ""

echo "✓ Setup complete!"