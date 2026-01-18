# prepare.ps1
# Generates the "mac-bootstrap" repository structure in the given output directory.
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\prepare.ps1 -OutDir .
# Optional:
#   -RepoName mac-bootstrap
#   -Force   (overwrite existing repo directory)

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutDir = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [string]$RepoName = "mac-bootstrap",

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Die([string]$msg) {
    Write-Error $msg
    exit 1
}

function Ensure-Dir([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

function Write-File([string]$path, [string]$content) {
    $dir = Split-Path -Parent $path
    Ensure-Dir $dir
    # Always write UTF-8 (no BOM) for cross-platform friendliness.
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $content.Replace("`r`n", "`n"), $utf8NoBom)
}

$cwd = (Get-Location).Path
$inRepoDir = ((Split-Path -Leaf $cwd) -ieq $RepoName)
$root = if ($inRepoDir) { $cwd } else { Join-Path $OutDir $RepoName }

if (Test-Path -LiteralPath $root) {
    if ($Force -and -not $inRepoDir) {
        Remove-Item -LiteralPath $root -Recurse -Force
        Ensure-Dir $root
    }
} else {
    Ensure-Dir $root
}

# Create folder skeleton
Ensure-Dir (Join-Path $root "Brewfiles")
Ensure-Dir (Join-Path $root "manifests")
Ensure-Dir (Join-Path $root "scripts")
Ensure-Dir (Join-Path $root "docs")
Ensure-Dir (Join-Path $root ".vscode")
Ensure-Dir (Join-Path $root ".devcontainer")
Ensure-Dir (Join-Path $root ".github")
Ensure-Dir (Join-Path $root ".github\prompts")

# -------------------------
# Documentation (English)
# -------------------------
Write-File (Join-Path $root "README.md") @"
# mac-bootstrap

A modular macOS bootstrap repository that provisions a fresh machine using:

- **Homebrew Bundle** via topic-based Brewfiles (`Brewfiles/`)
- **npm global packages** via a manifest (`manifests/npm-global.txt`)
- **VS Code extensions** via a manifest (`manifests/vscode-extensions.txt`)

## Quick start (on macOS)

From the repo root:

```bash
bash scripts/install-all.sh
```

Everyday setup only:

```bash
bash scripts/install.sh
```

Developer setup only:

```bash
bash scripts/install-dev.sh
```

Update everything:

```bash
bash scripts/update.sh
```

Cleanup:

```bash
bash scripts/cleanup.sh
```

Brew diagnostics:

```bash
bash scripts/fix-brew.sh
```

## Notes

* This repo is designed for **macOS**.
* Some casks may prompt for macOS confirmations (Gatekeeper, permissions).
* Secrets/tokens must never be committed. Use local `.env` files (gitignored) or a secret manager.
* VS Code extension installation requires the `code` CLI to be available in `PATH`.
"@

Write-File (Join-Path $root "docs\USAGE.md") @"

# Usage Guide

This repository provisions software using three manifest types:

1. Homebrew Bundle modules: `Brewfiles/Brewfile.*`
2. npm global tools: `manifests/npm-global.txt`
3. VS Code extensions: `manifests/vscode-extensions.txt`

## Install (everyday)

```bash
bash scripts/install.sh
```

Installs:

* base utilities
* office/PDF/email tools
* browsers/media tools

## Install (developer)

```bash
bash scripts/install-dev.sh
```

Installs:

* Java (Temurin 21) + build tools + Kotlin tooling
* Android + Flutter/Cordova prerequisites
* Containers + cloud tooling (Cloudflare/Azure/AKS)
* IoT tooling (Arduino/ESP32)

## Install (all)

```bash
bash scripts/install-all.sh
```

Runs `install.sh` + `install-dev.sh`.

## Update

```bash
bash scripts/update.sh
```

Updates brew formulas/casks and re-applies bundles. Also updates npm globals and ensures VS Code extensions are installed (if tooling is present).

## Cleanup

```bash
bash scripts/cleanup.sh
```

Runs `brew cleanup` and removes old caches where safe.

## Brew diagnostics

```bash
bash scripts/fix-brew.sh
```

Runs `brew doctor` and prints next steps.

## Manifests

### Brewfiles

Run one module manually:

```bash
brew bundle --file Brewfiles/Brewfile.office
```

### npm global tools

One package name per line (comments allowed):

```bash
xargs -I{} npm install -g {} < manifests/npm-global.txt
```

### VS Code extensions

One extension ID per line (comments allowed):

```bash
xargs -I{} code --install-extension {} < manifests/vscode-extensions.txt
```

"@

Write-File (Join-Path $root "docs\MODULES.md") @"

# Modules (Brewfiles)

Brewfiles are split by topic:

## Everyday modules

* `Brewfile.base` — CLI essentials and small utilities
* `Brewfile.office` — office/PDF/email/sync tools
* `Brewfile.browser-media` — browsers and multimedia/photo tools

## Developer modules

* `Brewfile.dev-java` — Java (Temurin 21) + jenv + Maven/Gradle + Kotlin tooling
* `Brewfile.dev-android` — Android Studio + SDK tools + adb/NDK + debugging helpers
* `Brewfile.dev-flutter-cordova` — Flutter (brew cask) + Node.js + helpers
* `Brewfile.dev-containers` — Docker CLI/Compose/Buildx + Colima + linters/scanners
* `Brewfile.dev-iot` — Arduino/ESP32 toolchain + serial tools
* `Brewfile.cloudflare` — cloudflared + wrangler + IaC helpers
* `Brewfile.azure` — Azure CLI + azcopy + kubernetes/AKS tooling + helpers

Adjust module membership by editing the corresponding Brewfile.
"@

# -------------------------

# Copilot / agent rules

# -------------------------

Write-File (Join-Path $root "AGENTS.md") @"

# mac-bootstrap — Agent Rules (AGENTS.md)

## Purpose

This repo provisions macOS machines using:

* Homebrew Bundle (topic Brewfiles under `Brewfiles/`)
* npm global tools (`manifests/npm-global.txt`)
* VS Code extensions (`manifests/vscode-extensions.txt`)
* thin bash wrappers under `scripts/`

## Guardrails

* Do not add secrets or tokens to the repository.
* Keep documentation in English.
* Prefer adding software to the correct Brewfile module instead of hardcoding installs in scripts.
* Keep scripts readable, safe, and non-interactive by default.

## Conventions

* Brewfiles: add short comments above entries.
* Manifests: one entry per line; allow `# comments`.
* Shell scripts: bash + `set -euo pipefail`, functions, clear logs.

## Validation

* Brewfiles must remain valid `brew bundle` manifests.
* Scripts should be ShellCheck-friendly.
* Install scripts must preserve the separation:

  * everyday: base + office + browser-media
  * dev: dev-*
  * all: invokes both
"@

Write-File (Join-Path $root ".github\copilot-instructions.md") @"

# Copilot Instructions for mac-bootstrap

You are assisting with a macOS provisioning repository.

## Repository intent

* Keep provisioning modular using `Brewfiles/Brewfile.*` modules.
* Prefer Homebrew Bundle (`brew bundle`) as the primary installation mechanism.
* Keep install scripts minimal: they orchestrate modules and manifests.

## Output expectations

* Produce concrete file edits (exact paths + contents).
* Keep documentation in English.
* Add short rationale comments for package intent.

## Guardrails

* Never add secrets/tokens to committed files.
* Do not introduce new dependency managers unless clearly justified.
* Avoid interactive prompts in scripts.

## Script style

* Use bash with `set -euo pipefail`.
* Use helper functions and clear logging.
"@

Write-File (Join-Path $root ".github\prompts\add-tool-to-module.prompt.md") @"

# Add a tool to a module

Task:

* Add a tool to the most appropriate Brewfile module in `Brewfiles/`.
* Add a one-line comment explaining why it belongs there.
* If not available via brew/cask, add it to:

  * `manifests/npm-global.txt` or
  * `manifests/vscode-extensions.txt`
* Update docs only if module usage changes.

Input:

* Tool name:
* Type: brew formula / cask / npm / vscode extension
* Rationale (1–2 lines):
"@

Write-File (Join-Path $root ".github\prompts\review-module-consistency.prompt.md") @"

# Review module consistency

Review `Brewfiles/`, `manifests/`, and `scripts/` for consistency:

* Modules referenced by scripts exist as Brewfiles.
* Brewfiles use correct brew/cask entries and include comments.
* Manifests are one entry per line and readable.
* Install scripts keep everyday vs dev separation intact.

Provide recommended fixes and exact file edits.
"@

# -------------------------

# Git ignore

# -------------------------

Write-File (Join-Path $root ".gitignore") @"

# macOS

.DS_Store
.AppleDouble
.LSOverride

# Logs

*.log
*.out

# Local env / secrets (never commit)

.env
.env.*
!.env.example
*.secrets.*
secrets/
.private/
**/private/

# Temporary files

*.tmp
*.temp
*.swp
*.swo
*~

# Node

node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Python

**pycache**/
*.py[cod]
.venv/
venv/

# Terraform / OpenTofu

.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log

# VS Code local caches

.vscode-test/
.history/

# Dev Containers local overrides

.devcontainer/.env
.devcontainer/.env.*
"@

# -------------------------

# Workspace + tasks

# -------------------------

Write-File (Join-Path $root "$RepoName.code-workspace") @"
{
"folders": [{ "path": "." }],
"settings": {
"files.eol": "\n",
"files.insertFinalNewline": true,
"files.trimTrailingWhitespace": true,
"editor.formatOnSave": true,
"editor.rulers": [100],
"yaml.validate": true,
"shellcheck.enable": true,
"shellcheck.run": "onSave",
"shellcheck.executablePath": "shellcheck",
"github.copilot.chat.codeGeneration.useInstructionFiles": true,
"chat.useAgentsMdFile": true,
"chat.useNestedAgentsMdFiles": true
},
"extensions": {
"recommendations": [
"ms-vscode.copilot",
"ms-vscode.copilot-chat",
"ms-vscode-remote.remote-containers",
"timonwong.shellcheck",
"foxundermoon.shell-format",
"DavidAnson.vscode-markdownlint",
"redhat.vscode-yaml",
"EditorConfig.EditorConfig"
]
}
}
"@

Write-File (Join-Path $root ".vscode\tasks.json") @"
{
"version": "2.0.0",
"tasks": [
{ "label": "mac-bootstrap: Install (everyday)", "type": "shell", "command": "bash", "args": ["scripts/install.sh"] },
{ "label": "mac-bootstrap: Install (dev)", "type": "shell", "command": "bash", "args": ["scripts/install-dev.sh"] },
{ "label": "mac-bootstrap: Install (all)", "type": "shell", "command": "bash", "args": ["scripts/install-all.sh"] },
{ "label": "mac-bootstrap: Update (all)", "type": "shell", "command": "bash", "args": ["scripts/update.sh"] },
{ "label": "mac-bootstrap: Cleanup (brew)", "type": "shell", "command": "bash", "args": ["scripts/cleanup.sh"] },
{ "label": "mac-bootstrap: Fix / Doctor (brew)", "type": "shell", "command": "bash", "args": ["scripts/fix-brew.sh"] }
]
}
"@

# -------------------------

# Devcontainer

# -------------------------

Write-File (Join-Path $root ".devcontainer\devcontainer.json") @"
{
"name": "mac-bootstrap (repo tooling)",
"build": { "dockerfile": "Dockerfile" },
"workspaceFolder": "/workspaces/mac-bootstrap",
"remoteUser": "node",
"customizations": {
"vscode": {
"extensions": [
"ms-vscode.copilot",
"ms-vscode.copilot-chat",
"timonwong.shellcheck",
"foxundermoon.shell-format",
"DavidAnson.vscode-markdownlint",
"redhat.vscode-yaml",
"EditorConfig.EditorConfig"
],
"settings": {
"files.eol": "\n",
"files.insertFinalNewline": true,
"files.trimTrailingWhitespace": true,
"editor.formatOnSave": true,
"shellcheck.run": "onSave",
"shellcheck.executablePath": "shellcheck",
"github.copilot.chat.codeGeneration.useInstructionFiles": true,
"chat.useAgentsMdFile": true,
"chat.useNestedAgentsMdFiles": true
}
}
},
"postCreateCommand": "npm -g i markdownlint-cli2 && echo 'Dev container ready.'"
}
"@

Write-File (Join-Path $root ".devcontainer\Dockerfile") @"
FROM mcr.microsoft.com/devcontainers/javascript-node:1-20-bookworm
USER root
RUN apt-get update
&& apt-get install -y --no-install-recommends shellcheck shfmt jq python3 python3-pip
&& rm -rf /var/lib/apt/lists/*
USER node
"@

# -------------------------

# Manifests: npm + VS Code extensions

# -------------------------

Write-File (Join-Path $root "manifests\npm-global.txt") @"

# npm global tools (one per line)

# Keep this list small; prefer project-local tooling where possible.

cordova          # Apache Cordova CLI (cross-platform apps)
firebase-tools   # Firebase CLI (optional; remove if not needed)
"@

Write-File (Join-Path $root "manifests\vscode-extensions.txt") @"

# VS Code extensions (one ID per line). Comments allowed on separate lines.

# Core quality / team workflows

EditorConfig.EditorConfig
dbaeumer.vscode-eslint
esbenp.prettier-vscode
redhat.vscode-yaml
DavidAnson.vscode-markdownlint
eamodio.gitlens
GitHub.vscode-pull-request-github

# Containers

ms-azuretools.vscode-docker
ms-vscode-remote.remote-containers

# Java

vscjava.vscode-java-pack
vscjava.vscode-gradle
vscjava.vscode-maven

# Flutter / Dart

Dart-Code.flutter
Dart-Code.dart-code

# Cordova

msjsdiag.cordova-tools

# IoT / Embedded (optional; remove if not needed)

platformio.platformio-ide
vscode-arduino.vscode-arduino-community

# Cloud/IaC (optional)

HashiCorp.terraform
OpenTofu.vscode-opentofu
cloudflare.cloudflare-workers-bindings-extension
"@

# -------------------------

# Brewfiles with comments (topic-based)

# -------------------------

Write-File (Join-Path $root "Brewfiles\Brewfile.base") @"

# Brewfile.base — CLI essentials and small productivity tools

# Better terminal

cask "iterm2"

# Clipboard history

cask "maccy"

# Menu bar system stats

cask "stats"

# Prevent sleep during presentations/downloads

cask "keepingyouawake"

# Password manager (local file-based)

cask "keepassxc"

# CLI essentials

brew "git"
brew "gh"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "bat"
brew "jq"
brew "zoxide"
"@

Write-File (Join-Path $root "Brewfiles\Brewfile.office") @"

# Brewfile.office — office/PDF/email/sync utilities

# Office suites (choose what you need)

cask "libreoffice-still"
cask "onlyoffice"

# Email client

cask "thunderbird"

# Notes (optional)

cask "joplin"

# PDF management (split/merge)

cask "pdfsam-basic"

# PDF viewer/annotation

cask "skim"

# Scanning frontend

cask "naps2"

# OCR for scanned PDFs (CLI)

brew "ocrmypdf"

# PDF utilities (text extraction, inspection)

brew "poppler"

# Diagramming

cask "drawio"

# File/folder diff & merge

cask "meld"

# Cloud file transfer/mount

cask "cyberduck"
cask "mountain-duck"

# Sync clients (optional; remove if not used)

cask "nextcloud"
cask "syncthing-app"
"@

Write-File (Join-Path $root "Brewfiles\Brewfile.browser-media") @"

# Brewfile.browser-media — browsers and multimedia/photo tools

# Browsers

cask "firefox"
cask "brave-browser"
cask "tor-browser"

# Media players

cask "iina"
cask "vlc"

# Video transcoding

cask "handbrake-app"

# Audio/video toolkit (CLI)

brew "ffmpeg"

# Image processing (CLI)

brew "imagemagick"

# Screen recording / streaming

cask "obs"

# RAW photo development (optional)

cask "rawtherapee"

# Image editor (optional)

cask "gimp"
"@

Write-File (Join-Path $root "Brewfiles\Brewfile.dev-java") @"

# Brewfile.dev-java — Java development (Temurin 21) + build tools

# Java 21 (LTS)

cask "temurin@21"

# Java version management

brew "jenv"

# Build tools

brew "maven"
brew "gradle"

# Kotlin compiler (optional; many projects use the Gradle plugin only)

brew "kotlin"

# Formatting / linting helpers

brew "google-java-format"
brew "ktlint"

# Developer editor

cask "visual-studio-code"
"@

Write-File (Join-Path $root "Brewfiles\Brewfile.dev-android") @"

# Brewfile.dev-android — Android tooling

# Android Studio

cask "android-studio"

# Android CLI tools (sdkmanager/avdmanager)

cask "android-commandlinetools"

# adb / fastboot

cask "android-platform-tools"

# Android NDK (for native builds, JNI)

cask "android-ndk"

# Handy Android screen mirroring/control

brew "scrcpy"
"@

Write-File (Join-Path $root "Brewfiles\Brewfile.dev-flutter-cordova") @"

# Brewfile.dev-flutter-cordova — Flutter + Cordova prerequisites

# Flutter SDK

cask "flutter"

# Node.js runtime for Cordova tooling

brew "node"

# Useful file watcher (optional)

brew "watchman"

# pnpm/yarn are optional; install if you need them

brew "pnpm"
brew "yarn"
"@

Write-File (Join-Path $root "Brewfiles\Brewfile.dev-containers") @"

# Brewfile.dev-containers — containers and related tooling

# Docker CLI

brew "docker"

# Docker Compose

brew "docker-compose"

# Docker Buildx plugin

brew "docker-buildx"

# Credential helper for Keychain

brew "docker-credential-helper"

# Lightweight Docker runtime alternative to Docker Desktop

brew "colima"

# Dockerfile linting

brew "hadolint"

# Image vulnerability scanning

brew "trivy"

# Inspect image layers / size issues

brew "dive"
"@

Write-File (Join-Path $root "Brewfiles\Brewfile.dev-iot") @"

# Brewfile.dev-iot — Arduino / ESP32 tooling

# Arduino CLI

brew "arduino-cli"

# Arduino IDE (optional GUI)

cask "arduino-ide"

# PlatformIO (CLI; pairs with VS Code PlatformIO extension)

brew "platformio"

# ESP flashing tools

brew "esptool"
brew "espflash"

# Serial monitors

brew "picocom"
brew "minicom"

# On-chip debugging (JTAG/SWD)

brew "open-ocd"

# AVR tooling (older Arduino boards)

brew "avrdude"

# DFU utility (for some boards)

brew "dfu-util"
"@

Write-File (Join-Path $root "Brewfiles\Brewfile.cloudflare") @"

# Brewfile.cloudflare — Cloudflare tooling

# Cloudflare Tunnel client

brew "cloudflared"

# Cloudflare Workers/Pages CLI

brew "cloudflare-wrangler"

# IaC helpers

brew "opentofu"
brew "sops"
brew "terraform-docs"
brew "cf-terraforming"
"@

Write-File (Join-Path $root "Brewfiles\Brewfile.azure") @"

# Brewfile.azure — Azure + AKS tooling

# Azure CLI

brew "azure-cli"

# Azure Storage transfer tool

brew "azcopy"

# Storage GUI (optional)

cask "microsoft-azure-storage-explorer"

# Kubernetes / AKS essentials

brew "kubernetes-cli"
brew "helm"
brew "kustomize"
brew "kubectx"
brew "k9s"
brew "stern"

# Manifest validation

brew "kubeconform"

# Secret management helpers

brew "sops"
brew "ksops"
brew "kubeseal"

# kubectl plugin manager

brew "krew"

# kubelogin (Entra auth plugin)

brew "Azure/kubelogin/kubelogin"
"@

# -------------------------

# Scripts (bash)

# -------------------------

Write-File (Join-Path $root "scripts_lib.sh") @'
#!/usr/bin/env bash
set -euo pipefail

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
'@

Write-File (Join-Path $root "scripts\install.sh") @'
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
'@

Write-File (Join-Path $root "scripts\install-dev.sh") @'
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
'@

Write-File (Join-Path $root "scripts\install-all.sh") @'
#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

bash "$ROOT_DIR/scripts/install.sh"
bash "$ROOT_DIR/scripts/install-dev.sh"
log "Full installation complete."
'@

Write-File (Join-Path $root "scripts\update.sh") @'
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
'@

Write-File (Join-Path $root "scripts\cleanup.sh") @'
#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

require_brew

log "Running brew cleanup..."
brew cleanup || true

# Optional: clean Homebrew cache (safe but may force re-downloads)

log "Pruning Homebrew cache (optional)..."
brew cleanup -s || true

log "Cleanup complete."
'@

Write-File (Join-Path $root "scripts\fix-brew.sh") @'
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
'@

Write-File (Join-Path $root "scripts\prepare.sh") @'
#!/usr/bin/env bash
set -euo pipefail

# Prepare the repository on macOS:

# - ensures scripts are executable

# - prints next steps

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

chmod +x "$ROOT_DIR/scripts"/*.sh || true

echo "[mac-bootstrap] Repo prepared."
echo "[mac-bootstrap] Next: bash scripts/install-all.sh"
'@

# Final message

Write-Host ""
Write-Host "Done. Repository created at:"
Write-Host "  $root"
Write-Host ""
Write-Host "Next steps on macOS:"
Write-Host "  cd $RepoName"
Write-Host "  bash scripts/prepare.sh"
Write-Host ""
