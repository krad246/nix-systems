args @ {
  inputs,
  pkgs,
  lib,
  ...
}: let
  inherit (inputs) mac-app-util;
  dockModule = mac-app-util.homeManagerModules.default;
  isSupported = builtins.hasAttr pkgs.stdenv.system mac-app-util.packages;
  importIfSupported = x: lib.mkIf isSupported x;
in {
  imports =
    [(importIfSupported (dockModule args))];
}
