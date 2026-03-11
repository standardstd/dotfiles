#!/usr/bin/env bash

echo "Installing VSCode extensions..."

cat vscode/extensions.txt | xargs -L 1 code --install-extension

echo "Extensions installed."