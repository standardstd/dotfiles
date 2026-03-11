#!/usr/bin/env bash

DOTFILES="$HOME/dotfiles"

echo "Creating symlinks..."

ln -sf "$DOTFILES/shell/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/shell/bashrc" "$HOME/.bashrc"

ln -sf "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"

ln -sf "$DOTFILES/vim/vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES/vim/ideavimrc" "$HOME/.ideavimrc"

ln -sf "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/nvim"
ln -sf "$DOTFILES/nvim/init.vim" "$HOME/.config/nvim/init.vim"

echo "Symlinks created."