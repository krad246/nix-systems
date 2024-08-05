{
  inputs,
  lib,
  modulesPath,
  ezModules,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports =
    [nixos-generators.nixosModules.all-formats]
    ++ [
      ezModules.gnome-desktop
      ezModules.nixos
    ]
    ++ [
      "${modulesPath}/profiles/installation-device.nix"
    ];

  # ISO system essentially boots into EFI on tmpfs
  boot.loader.grub.device = lib.mkDefault "nodev";
  fileSystems."/" = lib.mkDefault {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults"];
  };

  boot.supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  networking.hostName = lib.mkForce "nixos-iso-installer";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
