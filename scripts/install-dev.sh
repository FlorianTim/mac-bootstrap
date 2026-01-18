#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

require_brew
brew update

# Developer modules

brew_bundle "Brewfiles/Brewfile.dev-java"
brew_bundle "Brewfiles/Brewfile.dev-android"
brew_bundle "Brewfiles/Brewfile.dev-flutter-cordova"
brew_bundle "Brewfiles/Brewfile.dev-containers"
brew_bundle "Brewfiles/Brewfile.dev-iot"
brew_bundle "Brewfiles/Brewfile.cloudflare"
brew_bundle "Brewfiles/Brewfile.azure"

# Manifests

install_npm_globals
install_vscode_extensions

log "Developer installation complete."