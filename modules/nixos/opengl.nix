{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) modules;
in {
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = modules.mkIf pkgs.stdenv.isx86_64 true;
    };
  };
}
