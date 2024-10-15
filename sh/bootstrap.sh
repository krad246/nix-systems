#!/usr/bin/env bash

set -eux

SCRIPT="$(realpath "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

exec nix run "$SCRIPTPATH/../#bootstrap"
