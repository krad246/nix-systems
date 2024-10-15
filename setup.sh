#!/usr/bin/env bash

SCRIPT="$(realpath "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

source "$SCRIPTPATH/sh/install-nix.sh"
exec "$SCRIPTPATH/sh/bootstrap.sh"
