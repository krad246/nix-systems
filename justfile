#!/usr/bin/env just --justfile

# Pull in justfile bindings
import 'just-flake.just'

default:
    @just --list

setup:
  exec {{ justfile_directory() / "setup.sh" }}
