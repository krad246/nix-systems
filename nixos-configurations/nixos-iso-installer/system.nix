{
  inputs,
  lib,
  modulesPath,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports =
    [nixos-generators.nixosModules.all-formats]
    ++ [
      ../../nixos-modules/gnome-desktop.nix
      ../../nixos-modules/nixos
    ]
    ++ ["${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"];

  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults"];
  };

  boot.supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  networking.hostName = lib.mkForce "nixos-iso-installer";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
