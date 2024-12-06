{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) modules;
in {
  specialisation = modules.mkIf pkgs.stdenv.isLinux {
    wsl.configuration = import ./wsl.nix;
  };
}
