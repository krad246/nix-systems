outer @ {
  withSystem,
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixos-generators;
  entrypoint = inner @ {system, ...}: {
    imports =
      [nixos-generators.nixosModules.all-formats]
      ++ [
        ./configuration.nix
        ./stub-disko.nix
      ];

    formatConfigs = import ./specialisations/formats (outer // inner);
    specialisation = import ./specialisations/bootable (outer
      // {
        inherit (inner) pkgs;
      });

    nixpkgs.system = lib.modules.mkDefault system;
  };
in
  withSystem "x86_64-linux" entrypoint
