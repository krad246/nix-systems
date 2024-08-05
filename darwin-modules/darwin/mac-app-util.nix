{inputs, ...}: let
  inherit (inputs) mac-app-util;
in {
  imports = [mac-app-util.darwinModules.default];
}
