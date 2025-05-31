{
  withSystem,
  pkgs,
  ...
}: {
  fonts.fontconfig.enable = pkgs.stdenv.isLinux;
  home.packages =
    withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts.paths);
}
