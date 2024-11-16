{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) zen-browser;
in {
  home.packages = [zen-browser.packages.${pkgs.stdenv.system}.default];
}
