#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

require_brew
brew update

# Everyday modules

brew_bundle "Brewfiles/Brewfile.base"
brew_bundle "Brewfiles/Brewfile.office"
brew_bundle "Brewfiles/Brewfile.browser-media"

# Manifests (optional)

install_npm_globals
install_vscode_extensions

log "Everyday installation complete."