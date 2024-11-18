args @ {pkgs, ...}: let
  inherit (pkgs) lib;
in {
  packages = lib.attrsets.optionalAttrs pkgs.stdenv.isLinux {
    disko-install = import ./disko-install.nix args;
  };
}
