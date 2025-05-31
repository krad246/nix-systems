{
  withSystem,
  pkgs,
  ...
}: {
  fonts = {
    enableDefaultPackages = true;
    packages =
      withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts.paths);
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
