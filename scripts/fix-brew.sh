#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

if ! have_cmd brew; then
die "Homebrew is not installed. Install from [https://brew.sh/](https://brew.sh/)"
fi

log "Running brew doctor..."
brew doctor || true

log "Running brew config..."
brew config || true

log "If brew doctor reports issues, address them and re-run installs."