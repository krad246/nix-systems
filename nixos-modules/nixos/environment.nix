{lib, ...}: {
  imports = [
    ../../nixos-modules/default-users.nix
    ../../nixos-modules/flake-registry.nix
    ../../nixos-modules/locale.nix
    ../../nixos-modules/unfree.nix
  ];

  system.stateVersion = lib.trivial.release;
  documentation.enable = false;
}
