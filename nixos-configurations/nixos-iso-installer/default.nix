{lib, ...}: {
  imports = [
    ../../nixos-modules/nixos
    ../../nixos-modules/gnome-iso.nix
    ../../nixos-modules/flake-registry.nix
  ];

  networking.hostName = "nixos-iso-installer";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
