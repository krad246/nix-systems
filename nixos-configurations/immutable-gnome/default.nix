{lib, ...}: {
  imports = [
    ./system.nix
  ];

  networking.hostName = lib.mkForce "immutable-gnome";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
