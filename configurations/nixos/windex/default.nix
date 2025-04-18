{
  withSystem,
  lib,
  ...
}: let
  entrypoint = {system, ...}: {
    imports = [
      ./configuration.nix
      ./container.nix
    ];
    nixpkgs.system = lib.modules.mkDefault system;
  };
in
  withSystem "x86_64-linux" entrypoint
