{
  lib,
  pkgs,
  ...
}: {
  services = {
    xserver = {
      enable = true;
      videoDrivers = ["modesetting"];
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = lib.mkIf pkgs.stdenv.isx86_64 true;
    };
  };
}
