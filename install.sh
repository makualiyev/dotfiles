#!/usr/bin/env bash
#
# Idempotent bootstrap for these dotfiles.
#   ./install.sh            # link + packages + shell (everything)
#   ./install.sh link       # only create symlinks
#   ./install.sh packages   # only install apt packages + language tools
#   ./install.sh shell      # only switch default shell to zsh
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[!]\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# symlinking
# ---------------------------------------------------------------------------
backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP"
    warn "backing up existing $target -> $BACKUP/"
    mv "$target" "$BACKUP/"
  fi
}

symlink() {
  local src="$1" dest="$2"
  [ -e "$src" ] || return 0   # skip slots we don't have yet
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
    return 0                  # already linked correctly
  fi
  mkdir -p "$(dirname "$dest")"
  backup "$dest"
  ln -sfn "$src" "$dest"
  info "linked $dest"
}

link() {
  info "creating symlinks"
  # home/  -> files that must live directly in $HOME (.zshrc, .gitconfig, ...)
  if [ -d "$DOTFILES/home" ]; then
    shopt -s dotglob nullglob
    for f in "$DOTFILES"/home/*; do
      [ "$(basename "$f")" = ".gitkeep" ] && continue
      symlink "$f" "$HOME/$(basename "$f")"
    done
    shopt -u dotglob nullglob
  fi
  # config/ -> ~/.config/<name>  (XDG apps: git, tmux, htop, ...)
  if [ -d "$DOTFILES/config" ]; then
    for d in "$DOTFILES"/config/*; do
      [ -e "$d" ] || continue
      [ "$(basename "$d")" = ".gitkeep" ] && continue
      symlink "$d" "$HOME/.config/$(basename "$d")"
    done
  fi
}

# ---------------------------------------------------------------------------
# packages
# ---------------------------------------------------------------------------
packages() {
  if command -v apt-get >/dev/null 2>&1 && [ -f "$DOTFILES/packages/apt.txt" ]; then
    info "installing apt packages from packages/apt.txt"
    sudo apt-get update
    grep -vE '^\s*#|^\s*$' "$DOTFILES/packages/apt.txt" | xargs -r sudo apt-get install -y
  fi
  if [ -f "$DOTFILES/packages/tools.sh" ]; then
    info "installing language toolchains (packages/tools.sh)"
    bash "$DOTFILES/packages/tools.sh"
  fi
}

# ---------------------------------------------------------------------------
# default shell
# ---------------------------------------------------------------------------
shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ]; then
    warn "zsh is not installed yet — run './install.sh packages' first"
    return 0
  fi
  if [ "${SHELL:-}" = "$zsh_path" ]; then
    info "default shell already zsh"
    return 0
  fi
  info "setting default shell to zsh ($zsh_path)"
  # WSL note: chsh needs zsh listed in /etc/shells
  grep -qxF "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$zsh_path" || warn "chsh failed; add 'exec zsh' to ~/.bashrc as a fallback"
}

case "${1:-all}" in
  link)     link ;;
  packages) packages ;;
  shell)    shell ;;
  all)      packages; link; shell ;;
  *) echo "usage: $0 [all|link|packages|shell]"; exit 1 ;;
esac

info "done."
