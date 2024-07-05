{
  inputs,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports =
    [
      ./immutable-gnome.nix
      ./platform.nix
    ]
    ++ [nixos-generators.nixosModules.all-formats];

  networking.hostName = "immutable-gnome";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  formatConfigs.impermanence = _: let
    impermanence = import ./fetch-impermanence.nix;
  in {
    imports = [impermanence] ++ [../../nixos-modules/impermanence.nix] ++ [./formats/impermanence.nix];
    formatAttr = "impermanence";

    system.build.impermanence = import "${modulesPath}/../lib/make-disk-image.nix" {
      inherit config lib pkgs;
      diskSize = "auto";
      format = "raw";
    };
  };
}
