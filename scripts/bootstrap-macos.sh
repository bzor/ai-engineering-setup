#!/usr/bin/env bash
set -euo pipefail

brew install neovim tmux ripgrep fd git node yazi zoxide fzf
brew install --cask kitty
brew install --cask font-iosevka-term-nerd-font

# sketchybar (minimal status bar; third-party tap needs explicit trust)
brew tap FelixKratz/formulae
brew trust --formula felixkratz/formulae/sketchybar
brew install sketchybar
brew services start sketchybar

