{pkgs, ...}: {
  hardware = rec {
    opengl = {
      enable = true;
      driSupport32Bit = pkgs.stdenv.isx86_64;
    };

    graphics.enable32Bit = opengl.driSupport32Bit;
  };
}
