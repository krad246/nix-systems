#!/usr/bin/env just --justfile

flake := env_var('FLAKE_ROOT')
scripts := flake / "scripts"
runner := "runner"

default:
  @just --list

run VERB TASK *ARGS:
  {{ scripts / TASK / runner }} {{ VERB }} {{ ARGS }}
