#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_ROOT=""
MINIMAL_VIM=0
INSTALL_MINPAC=1
MINPAC_REF="v3.0.0"
BACKUP_CREATED=0

usage() {
  cat <<'EOF'
Usage: bash install.sh [options]

Options:
  --minimal-vim   Use _vimrc_min instead of _vimrc.
  --skip-minpac   Do not clone minpac.
  -h, --help      Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --minimal-vim)
      MINIMAL_VIM=1
      ;;
    --skip-minpac)
      INSTALL_MINPAC=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

backup_target() {
  local target="$1"
  local relative backup

  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return
  fi

  if [ "$BACKUP_CREATED" -eq 0 ]; then
    mkdir -p "$HOME/.dotfiles-backup"
    BACKUP_ROOT="$(mktemp -d "$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S).XXXXXX")"
    BACKUP_CREATED=1
  fi

  relative="${target#"$HOME"/}"
  backup="$BACKUP_ROOT/$relative"
  mkdir -p "$(dirname -- "$backup")"
  mv -- "$target" "$backup"
  printf 'Backed up: %s -> %s\n' "$target" "$backup"
}

link_target() {
  local source="$1"
  local target="$2"
  local current=""

  mkdir -p "$(dirname -- "$target")"

  if [ -L "$target" ]; then
    current="$(readlink "$target")"
    if [ "$current" = "$source" ]; then
      printf 'Already linked: %s\n' "$target"
      return
    fi
  fi

  backup_target "$target"
  ln -s "$source" "$target"
  printf 'Linked: %s -> %s\n' "$target" "$source"
}

link_target "$REPO_DIR/_bashrc" "$HOME/.bashrc"
link_target "$REPO_DIR/_bash_env" "$HOME/.bash_env"
link_target "$REPO_DIR/_tmux.conf" "$HOME/.tmux.conf"

if [ "$MINIMAL_VIM" -eq 1 ]; then
  link_target "$REPO_DIR/_vimrc_min" "$HOME/.vimrc"
else
  link_target "$REPO_DIR/_vimrc" "$HOME/.vimrc"
fi

NVIM_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}/nvim"
NVIM_DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}/nvim"
link_target "$REPO_DIR/nvim" "$NVIM_CONFIG_HOME"

install_minpac() {
  local destination="$1"

  if [ -d "$destination/.git" ]; then
    printf 'minpac already installed: %s\n' "$destination"
    return
  fi

  mkdir -p "$(dirname -- "$destination")"
  git clone --depth 1 --branch "$MINPAC_REF" \
    https://github.com/k-takata/minpac.git "$destination"
}

if [ "$INSTALL_MINPAC" -eq 1 ]; then
  if command -v git >/dev/null 2>&1; then
    install_minpac "$HOME/.vim/pack/minpac/opt/minpac"
    install_minpac "$NVIM_DATA_HOME/site/pack/minpac/opt/minpac"
  else
    printf 'git is not installed; skipping minpac installation.\n' >&2
  fi
fi

if [ "$BACKUP_CREATED" -eq 1 ]; then
  printf '\nExisting files were backed up under: %s\n' "$BACKUP_ROOT"
fi

printf '\nInstallation complete.\n'
