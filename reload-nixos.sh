#!/usr/bin/env bash

currentSystem() {
  nix-instantiate --eval --expr 'builtins.currentSystem'
}

sudo nixos-rebuild switch --flake "${FLAKE_ROOT:-.}"
