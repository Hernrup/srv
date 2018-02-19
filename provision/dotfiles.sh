#!/usr/bin/env bash
set -e
mkdir -p ~/src

git clone https://github.com/Hernrup/dotfiles.git ~/src/dotfiles || true
pushd ~/src/dotfiles
python3 install_dot_files.py ~
popd
