#!/usr/bin/env bash

echo "Bootstrapping dev environment..."

./scripts/install-tools.sh
./scripts/symlink.sh
./scripts/install-vscode-extensions.sh

echo "Setup complete."