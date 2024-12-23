{
  withSystem,
  pkgs,
  ...
}: {
  fonts.fontconfig.enable = pkgs.stdenv.isLinux;
  home.packages = with pkgs; [
    (withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts))
  ];
}
