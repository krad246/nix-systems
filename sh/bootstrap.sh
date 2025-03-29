#!/usr/bin/env bash

SCRIPT="$(realpath "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

allow() {
  git config --global --add safe.directory "$(realpath "$1")"
  git config --global --add safe.directory "$(realpath "$1/.git")"
}

allow "$SCRIPTPATH/.."

_nix() {
  if ! command -v nix; then
    NP_GIT="$(command -v git)" \
    SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt \
      "$SCRIPTPATH/nix-portable" nix "$@"
  else
    "$(command -v nix)" "$@"
  fi
}

_nix --option experimental-features 'nix-command flakes' --option keep-going true \
  run "$SCRIPTPATH/../#bootstrap" --fallback -- "$@"
