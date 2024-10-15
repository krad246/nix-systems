#!/usr/bin/env bash

set -eux

if ! command -v nix; then
    sh <(curl -L https://nixos.org/nix/install) \
        --daemon --yes \
        --nix-extra-conf-file <(echo 'experimental-features = nix-command flakes')

    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
fi
