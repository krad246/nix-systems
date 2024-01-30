#!/usr/bin/env bash

ARGS=(
  --flake "${FLAKE_ROOT:-.}"
)

if command -v darwin-rebuild &>/dev/null; then
  darwin-rebuild switch "${ARGS[@]}" "$@"
else
  nix run LnL7/nix-darwin#darwin-rebuild switch "${ARGS[@]}" "$@"
fi
