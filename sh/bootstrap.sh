#!/usr/bin/env bash

set -eux

SCRIPT="$(realpath "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

allow() {
  git config --global --add safe.directory "$(realpath "$1")"
  git config --global --add safe.directory "$(realpath "$1/.git")"
}

allow "$SCRIPTPATH/.."

exec nix \
  --option experimental-features 'nix-command flakes' \
  run "$SCRIPTPATH/../#bootstrap" -- "$@"
