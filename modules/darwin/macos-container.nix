{
  withSystem,
  pkgs,
  ...
}: let
  container =
    withSystem pkgs.stdenv.system ({inputs', ...}: inputs'.nixos-unstable.legacyPackages.container);
in {
  home.packages = [
    container
  ];
}
