#!/usr/bin/env just --justfile

# Pull in justfile bindings
import 'just-flake.just'

default:
    @just --list

# Generic dispatcher
run BUILDER VERB *ARGS:
    @exec just {{ BUILDER }} {{ VERB }} {{ ARGS }}


build BUILDER *ARGS: (run BUILDER "build" ARGS)

switch BUILDER *ARGS: (run BUILDER "switch" ARGS)

test BUILDER *ARGS: (run BUILDER "test" ARGS)


darwin SUBCOMMAND *ARGS: (run "darwin-rebuild" SUBCOMMAND ARGS)

nixos SUBCOMMAND *ARGS: (run "nixos-rebuild" SUBCOMMAND ARGS)

home SUBCOMMAND *ARGS: (run "home-manager" SUBCOMMAND ARGS)

flake SUBCOMMAND *ARGS: (run "nix" "flake" SUBCOMMAND ARGS)

install CONFIG DEVICE +ARGS='': (run CONFIG "install" DEVICE ARGS)
