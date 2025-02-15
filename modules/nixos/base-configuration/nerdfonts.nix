{
  withSystem,
  pkgs,
  ...
}: {
  fonts = {
    enableDefaultPackages = true;
    packages = [
      (withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts))
    ];
    fontDir = {
      enable = true;
    };
    fontconfig = {
      enable = true;
      cache32Bit = true;
      includeUserConf = true;
      hinting = {
      };
      defaultFonts = {
      };
    };
  };
}
