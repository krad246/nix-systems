#!/usr/bin/env just --justfile

flake := env_var_or_default('FLAKE_ROOT')
scripts := flake / "scripts"
tools := flake / "tools"
runner := "runner"

default:
  @just --list

run VERB TASK *ARGS:
  nix develop --command {{ scripts / TASK / runner }} {{ VERB }} {{ ARGS }}

develop:
  {{ flake / "bootstrap.bash" }}

commit MESSAGE *FLAGS:
  nix develop --command git add {{ flake }}
  nix develop --command git -C {{ flake }} {{ FLAGS }} commit -m "{{ MESSAGE }}"
