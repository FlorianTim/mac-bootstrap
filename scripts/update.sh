#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

require_brew

log "Updating Homebrew..."
brew update
brew upgrade

# Re-apply all bundles to ensure consistency

for f in "$ROOT_DIR"/Brewfiles/Brewfile.*; do
[[ -f "$f" ]] || continue
rel="Brewfiles/$(basename "$f")"
brew_bundle "$rel"
done

# Update npm globals (best-effort)

if have_cmd npm; then
log "Updating npm global packages..."
npm update -g || true
fi

# Ensure VS Code extensions (best-effort)

install_vscode_extensions

log "Update complete."