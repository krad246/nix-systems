{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) modules;
in {
  specialisation = modules.mkIf pkgs.stdenv.isDarwin {
    darwin.configuration = import ./darwin.nix;
  };
}
