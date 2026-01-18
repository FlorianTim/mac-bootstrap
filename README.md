# mac-bootstrap

A modular macOS bootstrap repository that provisions a fresh machine using:

- **Homebrew Bundle** via topic-based Brewfiles (Brewfiles/)
- **npm global packages** via a manifest (manifests/npm-global.txt)
- **VS Code extensions** via a manifest (manifests/vscode-extensions.txt)

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
* Secrets/tokens must never be committed. Use local .env files (gitignored) or a secret manager.
* VS Code extension installation requires the code CLI to be available in PATH.
