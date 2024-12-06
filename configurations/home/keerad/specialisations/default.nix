{
  lib,
  pkgs,
  ...
}: let
  linux = import ./linux;
in {
  imports = [linux.default.configuration];

  specialisation = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux linux;
}
