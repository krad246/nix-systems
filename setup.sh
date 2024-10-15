#!/usr/bin/env bash

set -eux

SCRIPT="$(realpath "$0")"
SCRIPTPATH="$(dirname "$SCRIPT")"

source "$SCRIPTPATH/sh/install-nix.sh"
exec "$SCRIPTPATH/sh/bootstrap.sh"
