{
  withSystem,
  inputs,
  self,
  config,
  lib,
  specialArgs,
  ...
}: let
  inherit (inputs) nixos-generators;
  entrypoint = {
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

    formatConfigs = import ./specialisations/formats {inherit self config lib pkgs specialArgs;};
    specialisation = import ./specialisations {inherit self;};

    nixpkgs.system = lib.modules.mkDefault system;
  };
in
  withSystem "x86_64-linux" entrypoint
