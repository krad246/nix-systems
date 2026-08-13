#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd -P)"

# shellcheck source=sh/install-nix.sh
source "$root/sh/install-nix.sh"

# shellcheck source=sh/bootstrap.sh
exec "$root/sh/bootstrap.sh" "$@"
