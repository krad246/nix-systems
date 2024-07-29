{lib, ...}: {
  imports = [../../nixos-modules/locale.nix] ++ [../../nixos-modules/nix-daemon.nix];

  system.stateVersion = lib.trivial.release;
  documentation.enable = false;
}
