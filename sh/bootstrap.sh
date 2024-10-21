#!/usr/bin/env bash

set -eux

SCRIPT="$(realpath "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

allow() {
    git config --global --add safe.directory "$1"
    git config --global --add safe.directory "$1/.git"
}

allow "$SCRIPTPATH/.." && exec nix run "$SCRIPTPATH/../#bootstrap"
