#!/usr/bin/env bash

SCRIPT="$(realpath "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

# shellcheck source=sh/install-nix.sh
source "$SCRIPTPATH/sh/install-nix.sh"

# shellcheck source=sh/bootstrap.sh
exec "$SCRIPTPATH/sh/bootstrap.sh" "$@"
