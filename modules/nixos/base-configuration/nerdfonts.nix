{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = true;
    packages = pkgs.krad246.term-fonts.paths;
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
