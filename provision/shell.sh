#!/usr/bin/env bash
set -e

sudo apt install zsh
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell || true

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.build/fzf || true
~/.build/fzf/install --all

# Fetch tmux plugin manager
git clone git@github.com:tmux-plugins/tpm.git ~/.tmux/plugins/tpm || true

sudo chsh -s /bin/zsh $USER
