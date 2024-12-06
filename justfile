#!/usr/bin/env just --justfile

flake := env_var_or_default('FLAKE_ROOT', justfile_directory())
hostname := env_var_or_default('HOSTNAME', shell('hostname'))
tmpdir := shell('mktemp -d')
whoami := shell('whoami')

# List all of the recipes and groups.
[group('summary')]
default:
    @just --list

# Pull in justfile bindings

import? 'just-flake.just'

# Enter a `nix` devShell in this repository.
[group('dev')]
setup:
    exec {{ flake / "setup.sh" }}

[group('dev')]
clean *ARGS:
    git clean -fdx {{ ARGS }}
