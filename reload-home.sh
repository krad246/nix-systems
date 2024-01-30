#!/usr/bin/env bash

ARGS=(
  --flake "${FLAKE_ROOT:-.}"
  -b backup
)

if command -v home-manager &>/dev/null; then
  home-manager switch "${ARGS[@]}" "$@"
else
  nix run home-manager/master -- init --switch "${ARGS[@]}" "$@"
  home-manager switch "${ARGS[@]}" "$@"
fi
