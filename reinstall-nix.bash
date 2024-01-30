#!/usr/bin/env bash

sudo mv /etc/zshrc.backup-before-nix /etc/zshrc
sudo mv /etc/bashrc.backup-before-nix /etc/bashrc
sudo mv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc

sh <(curl -L https://nixos.org/nix/install) --daemon --yes
