#!/usr/bin/env bash

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPTPATH="$(dirname "$SCRIPT")"

[[ "${VERBOSE:-0}" -eq 1 ]] && set -v
[[ "${DEBUG:-0}" -eq 1 ]] && set -x

nix() {
    command nix --extra-experimental-features 'nix-command flakes' "$@"
}

allow() {
    nix run nixpkgs\#git -- config --local --add safe.directory "$1"
    nix run nixpkgs\#direnv -- allow "$1"
    nix shell nixpkgs\#git --command nix --extra-experimental-features 'nix-command flakes' develop --accept-flake-config
}

allow "$SCRIPTPATH"
