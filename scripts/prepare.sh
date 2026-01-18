#!/usr/bin/env bash
set -euo pipefail

# Prepare the repository on macOS:

# - ensures scripts are executable

# - prints next steps

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

chmod +x "$ROOT_DIR/scripts"/*.sh || true

echo "[mac-bootstrap] Repo prepared."
echo "[mac-bootstrap] Next: bash scripts/install-all.sh"