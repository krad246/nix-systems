{lib, ...}: {
  imports = [./kernel-modules.nix ./services.nix];

  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = lib.trivial.release;
}
