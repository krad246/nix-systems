args @ {
  inputs,
  self,
  lib,
  pkgs,
  ...
}: let
  inherit (args) specialArgs;
in
  pkgs.writeShellApplication {
    name = "devour-flake";

    text = let
      bin = lib.meta.getExe (pkgs.callPackage inputs.devour-flake {});
    in ''
      set -x
      ${bin} "${self}" \
        ${lib.strings.concatStringsSep " " specialArgs.nixArgs} \
      "$@"
    '';
  }
