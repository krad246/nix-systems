args @ {
  inputs,
  lib,
  ...
}: let
  inherit (inputs) mac-app-util;
in
  lib.mkMerge [
    (mac-app-util.homeManagerModules.default args)
  ]
