#!/usr/bin/env just --justfile

flake := env_var_or_default('FLAKE_ROOT', justfile_directory())
hostname := env_var_or_default('HOSTNAME', shell('hostname'))
tmpdir := shell('mktemp -d')
whoami := shell('whoami')
direnv_dir := (flake / ".direnv")

# List all of the recipes and groups.
[group('summary')]
help:
    @just --list

alias default := help

# Pull in justfile bindings

import? 'just-flake.just'

# Enter a `nix` devShell in this repository.
[group('direnv')]
setup:
    exec {{ flake / "setup.sh" }}

# Clear all devShell caches.
[group('direnv')]
clean *ARGS: && reload
    git clean -fdx {{ ARGS }}

# Reload the direnv context.
[group('direnv')]
reload:
    direnv reload
