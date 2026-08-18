# dotfiles

Portable configuration for my machines (WSL2 / Ubuntu 24.04 + laptop).
Zsh + oh-my-zsh, Python via `uv`, Node via `nvm`.

## Install on a fresh machine

```bash
git clone https://github.com/makualiyev/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh          # packages + symlinks + default shell
```

Or piecemeal:

```bash
make packages   # apt packages + uv/nvm/oh-my-zsh
make link       # symlink configs into $HOME and ~/.config
make shell      # switch default shell to zsh
```

`install.sh` is idempotent — safe to re-run. Existing real files are moved to
`~/.dotfiles-backup/<timestamp>/` before a symlink replaces them.

## Layout

| path         | purpose                                                        |
|--------------|----------------------------------------------------------------|
| `home/`      | dotfiles symlinked directly into `$HOME` (`.zshrc`, `.gitconfig`, `.vimrc`, ...) |
| `config/`    | dirs symlinked into `~/.config/<name>` (XDG apps: git, tmux, htop, ...) |
| `shell/`     | shared zsh snippets sourced from `.zshrc` (aliases, exports, functions) |
| `packages/`  | `apt.txt` package manifest + `tools.sh` for uv/nvm/oh-my-zsh    |
| `local/`     | **gitignored** per-machine + secret overrides (see below)      |

## Per-machine differences & secrets

Nothing secret or machine-specific lives in the repo. Each rc file ends with:

```sh
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

Put work proxies, laptop-only `PATH` entries, API tokens, etc. in
`~/.zshrc.local` (or `~/.gitconfig.local` via git's `[include]`). These are
gitignored and never leave the machine.

## WSL note

Terminal emulator (Windows Terminal) settings and fonts live on the **Windows**
side, not in WSL, so they can't be symlinked. Copies are kept under `windows/`
for reference and must be applied manually.
