{
  lib,
  pkgs,
  ...
}: {
  specialisation = lib.mkIf pkgs.stdenv.isLinux {
    base-graphical.configuration = import ./base-graphical.nix;
    nixos-system.configuration = import ./nixos-system.nix;
  };
}
