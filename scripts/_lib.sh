#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=_lib.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() { printf '[mac-bootstrap] %s\n' "$*"; }
die() { printf '[mac-bootstrap] ERROR: %s\n' "$*" >&2; exit 1; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

require_brew() {
  if ! have_cmd brew; then
    die "Homebrew not found. Install it first: [https://brew.sh/](https://brew.sh/)"
  fi
  if ! brew --version >/dev/null 2>&1; then
    die "brew exists but is not working. Try: bash scripts/fix-brew.sh"
  fi
  if ! have_cmd brew; then
    die "brew command not available."
  fi
}

brew_bundle() {
  local file="$1"
  log "brew bundle: $file"
  brew bundle --file "$ROOT_DIR/$file"
}

install_npm_globals() {
  local f="$ROOT_DIR/manifests/npm-global.txt"
  if ! have_cmd npm; then
    log "npm not found; skipping npm global tools."
    return 0
  fi
  if [[ ! -f "$f" ]]; then
    log "npm manifest not found; skipping."
    return 0
  fi
  log "Installing npm global tools from $f"

# Strip comments and empty lines

  grep -v '^\s*#' "$f" | grep -v '^\s*$' | while IFS= read -r line; do
    # allow inline comments after package name
    pkg="${line%%#*}"
    pkg="$(echo "$pkg" | xargs)"
    [[ -z "$pkg" ]] && continue
    log "npm -g install $pkg"
    npm install -g "$pkg"
  done
}

install_vscode_extensions() {
  local f="$ROOT_DIR/manifests/vscode-extensions.txt"
  if ! have_cmd code; then
    log "VS Code 'code' CLI not found; skipping extension install."
    log "Hint: In VS Code -> Command Palette -> 'Shell Command: Install code command in PATH'"
    return 0
  fi
  if [[ ! -f "$f" ]]; then
    log "VS Code extensions manifest not found; skipping."
    return 0
  fi
  log "Installing VS Code extensions from $f"
  grep -v '^\s*#' "$f" | grep -v '^\s*$' | while IFS= read -r line; do
    ext="${line%%#*}"
    ext="$(echo "$ext" | xargs)"
    [[ -z "$ext" ]] && continue
    log "code --install-extension $ext"
    code --install-extension "$ext" >/dev/null || true
  done
}
