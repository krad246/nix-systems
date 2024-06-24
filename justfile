#!/usr/bin/env just --justfile

flake := justfile_directory()
scripts := flake / "scripts"
tools := flake / "tools"

default:
  @just --list

run VERB TARGET *ARGS:
  FLAKE_ROOT={{flake}} \
    {{ scripts / TARGET / "runner" }} {{ VERB }} {{ ARGS }}

exec VERB TARGET *ARGS: (run VERB TARGET ARGS)

docker VERB *ARGS: (exec VERB "in-docker" ARGS)

build TARGET *ARGS: (exec "build" TARGET ARGS)

check *ARGS: (exec "check" "flake" ARGS)

switch PLATFORM *ARGS: (exec "switch" PLATFORM ARGS)
