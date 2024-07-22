{
  inputs,
  lib,
  modulesPath,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports = [
    nixos-generators.nixosModules.all-formats
  ];

  formatConfigs = let
    isoImports =
      [
        "${modulesPath}/installer/cd-dvd/iso-image.nix"
        "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
      ]
      ++ [
        ../../nixos-modules/flake-registry.nix
        ../../nixos-modules/gnome-desktop.nix
        ../../nixos-modules/nixos
      ];
  in rec {
    iso = _: {
      imports = isoImports;
    };

    install-iso = iso;
    install-iso-hyperv = iso;
  };

  boot.supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  networking.hostName = "nixos-iso-installer";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
