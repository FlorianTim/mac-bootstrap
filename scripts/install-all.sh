#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

bash "$ROOT_DIR/scripts/install.sh"
bash "$ROOT_DIR/scripts/install-dev.sh"
log "Full installation complete."