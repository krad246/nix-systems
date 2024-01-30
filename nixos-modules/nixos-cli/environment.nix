{
  pkgs,
  lib,
  ...
}: {
  imports = [./packages.nix];

  system = {
    # Include the usual suspects for cache warming (we'll be installing stuff dependent on it).
    extraDependencies = with pkgs; [stdenv stdenvNoCC busybox toybox];
    stateVersion = lib.trivial.release;
  };
}
