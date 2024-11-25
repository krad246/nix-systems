{
  lib,
  pkgs,
  ...
}: {
  specialisation = lib.mkIf pkgs.stdenv.isLinux {
    wsl.configuration = import ./wsl.nix;
  };
}
