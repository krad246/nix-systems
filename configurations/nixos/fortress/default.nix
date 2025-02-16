{
  withSystem,
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixos-generators;
  entrypoint = {system, ...}: {
    imports =
      [nixos-generators.nixosModules.all-formats]
      ++ [
        ./configuration.nix
        ./stub-disko.nix
      ];

    formatConfigs = import ./specialisations/formats;
    specialisation = import ./specialisations/bootable;

    nixpkgs.system = lib.modules.mkDefault system;
  };
in
  withSystem "x86_64-linux" entrypoint
