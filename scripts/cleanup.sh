#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=_lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

require_brew

log "Running brew cleanup..."
brew cleanup || true

# Optional: clean Homebrew cache (safe but may force re-downloads)

log "Pruning Homebrew cache (optional)..."
brew cleanup -s || true

log "Cleanup complete."