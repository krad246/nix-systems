#!/usr/bin/env just --justfile

# Pull in justfile bindings
import 'just-flake.just'

default:
    @just --list

# Generic dispatcher
run BUILDER VERB *ARGS:
    @exec just {{ BUILDER }} {{ VERB }} {{ ARGS }}

# Flake related subcommands. Syntax: just flake <subcommand>
flake SUBCOMMAND *ARGS: (run "nix" "flake" SUBCOMMAND "--inputs-from $FLAKE_ROOT" ARGS)
