#!/usr/bin/env bash -eux

SCRIPT="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPTPATH="$(dirname "$SCRIPT")"

nix() {
    command nix --extra-experimental-features 'nix-command flakes' "$@"
}

allow() {
    nix run nixpkgs\#git -- config --global --add safe.directory "$1"
    eval "$(nix shell nixpkgs\#direnv --command direnv allow "$1" && direnv hook bash)"
}

allow "$SCRIPTPATH"
