{
  lib,
  pkgs,
  ...
}: {
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = lib.modules.mkIf pkgs.stdenv.isx86_64 true;
    };
  };
}
