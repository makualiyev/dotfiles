#!/usr/bin/env bash
#
# Language toolchains & shell framework that don't come from apt.
# Idempotent: each block is skipped if already present.
#
set -euo pipefail
info() { printf '\033[36m==>\033[0m %s\n' "$*"; }

# --- oh-my-zsh -------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "installing oh-my-zsh"
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- uv (Python) -----------------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  info "installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# --- nvm (Node) ------------------------------------------------------------
if [ ! -d "$HOME/.nvm" ]; then
  info "installing nvm"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
  info "run 'nvm install --lts' after opening a new shell"
fi
