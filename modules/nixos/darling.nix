{
  lib,
  pkgs,
  ...
}: {
  programs.darling.enable = lib.modules.mkIf pkgs.stdenv.isx86_64 true;
}
