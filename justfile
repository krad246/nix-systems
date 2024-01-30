#!/usr/bin/env just --justfile

flake := justfile_directory()
scripts := flake / "scripts"
tools := flake / "tools"

default:
  @just --list

run VERB TASK *ARGS:
  FLAKE_ROOT=${FLAKE_ROOT:-{{flake}}} {{ scripts / TASK / "runner" }} {{ VERB }} {{ ARGS }}

build TASK *ARGS: (run "build" TASK ARGS)
