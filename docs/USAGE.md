
# Usage Guide

This repository provisions software using three manifest types:

1. Homebrew Bundle modules: Brewfiles/Brewfile.*
2. npm global tools: manifests/npm-global.txt
3. VS Code extensions: manifests/vscode-extensions.txt

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

Runs install.sh + install-dev.sh.

## Update

```bash
bash scripts/update.sh
```

Updates brew formulas/casks and re-applies bundles. Also updates npm globals and ensures VS Code extensions are installed (if tooling is present).

## Cleanup

```bash
bash scripts/cleanup.sh
```

Runs brew cleanup and removes old caches where safe.

## Brew diagnostics

```bash
bash scripts/fix-brew.sh
```

Runs brew doctor and prints next steps.

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
