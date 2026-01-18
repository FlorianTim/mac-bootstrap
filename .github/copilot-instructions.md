
# Copilot Instructions for mac-bootstrap

You are assisting with a macOS provisioning repository.

## Repository intent

* Keep provisioning modular using Brewfiles/Brewfile.* modules.
* Prefer Homebrew Bundle (brew bundle) as the primary installation mechanism.
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

* Use bash with set -euo pipefail.
* Use helper functions and clear logging.
