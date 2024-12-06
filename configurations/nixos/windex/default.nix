{
  withSystem,
  lib,
  ...
}: let
  entrypoint = {system, ...}: {
    imports = [./windex.nix];
    nixpkgs.system = lib.modules.mkDefault system;
  };
in
  withSystem "x86_64-linux" entrypoint
