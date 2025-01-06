{
  withSystem,
  pkgs,
  ...
}: {
  home.packages = [(withSystem pkgs.stdenv.system ({inputs', ...}: inputs'.zen-browser.packages.default))];
}
