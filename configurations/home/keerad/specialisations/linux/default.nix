{
  lib,
  pkgs,
  ...
}: {
  specialisation = lib.modules.mkIf pkgs.stdenv.isLinux {
    wsl.configuration = import ./wsl.nix;
  };
}
