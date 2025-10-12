{pkgs, ...}: {
  fonts.fontconfig.enable = pkgs.stdenv.isLinux;
  home.packages = pkgs.krad246.term-fonts.paths;
}
