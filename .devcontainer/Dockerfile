# Dev container is for editing/linting the repo (not for running macOS installs)
# Base includes Node.js for markdown tooling.
FROM mcr.microsoft.com/devcontainers/javascript-node:1-20-bookworm

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     shellcheck \
     shfmt \
     jq \
     python3 \
     python3-pip \
  && rm -rf /var/lib/apt/lists/*

USER node
