{
  withSystem,
  inputs,
  self,
  lib,
  modulesPath,
  specialArgs,
  ...
}: let
  inherit (inputs) nixos-generators;
  entrypoint = {
    config,
    pkgs,
    system,
    ...
  }: {
    imports =
      [nixos-generators.nixosModules.all-formats]
      ++ [
        ./configuration.nix
        ./stub-disko.nix
      ];

    formatConfigs = import ./specialisations/formats {
      inherit self config lib pkgs modulesPath specialArgs;
    };

    specialisation = import ./specialisations {
      inherit inputs self config lib pkgs modulesPath specialArgs;
    };

    nixpkgs.system = lib.modules.mkDefault system;
  };
in
  withSystem "x86_64-linux" entrypoint
