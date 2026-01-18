
# mac-bootstrap â€” Agent Rules (AGENTS.md)

## Purpose

This repo provisions macOS machines using:

* Homebrew Bundle (topic Brewfiles under Brewfiles/)
* npm global tools (manifests/npm-global.txt)
* VS Code extensions (manifests/vscode-extensions.txt)
* thin bash wrappers under scripts/

## Guardrails

* Do not add secrets or tokens to the repository.
* Keep documentation in English.
* Prefer adding software to the correct Brewfile module instead of hardcoding installs in scripts.
* Keep scripts readable, safe, and non-interactive by default.

## Conventions

* Brewfiles: add short comments above entries.
* Manifests: one entry per line; allow # comments.
* Shell scripts: bash + set -euo pipefail, functions, clear logs.

## Validation

* Brewfiles must remain valid brew bundle manifests.
* Scripts should be ShellCheck-friendly.
* Install scripts must preserve the separation:

  * everyday: base + office + browser-media
  * dev: dev-*
  * all: invokes both
