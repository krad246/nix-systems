#!/usr/bin/env just --justfile

# Pull in justfile bindings
import? 'just-flake.just'

default:
    @just --list

# Enter a `nix` devShell in this repository.
[group('dev')]
setup:
  exec {{ justfile_directory() / "setup.sh" }}
