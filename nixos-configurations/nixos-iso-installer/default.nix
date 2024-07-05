{
  inputs,
  lib,
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
    ];

  networking.hostName = "nixos-iso-installer";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
