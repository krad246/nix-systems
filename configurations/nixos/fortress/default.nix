{
  withSystem,
  lib,
  ...
}: let
  entrypoint = {system, ...}: {
    imports = [
      ./empty-disko.nix
      ./fortress.nix
      ./specialisations
    ];

    nixpkgs.system = lib.modules.mkDefault system;
  };
in
  withSystem "x86_64-linux" entrypoint
