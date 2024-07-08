{
  inputs,
  lib,
  modulesPath,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports =
    [
      ../../nixos-modules/cachix.nix
      ../../nixos-modules/docker.nix
      ../../nixos-modules/flake-registry.nix
      ../../nixos-modules/gnome-desktop.nix
      ../../nixos-modules/nixos
      ../../nixos-modules/vscode-server.nix
    ]
    ++ [
      nixos-generators.nixosModules.all-formats
      "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    ];

  boot.supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  networking.hostName = "nixos-iso-installer";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
