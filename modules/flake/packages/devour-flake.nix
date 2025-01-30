{
  inputs,
  self,
  lib,
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "devour-flake";

  text = let
    bin = lib.meta.getExe (pkgs.callPackage inputs.devour-flake {});
  in ''
    set -x
    ${bin} "${self}" \
      ${lib.strings.concatStringsSep " " lib.krad246.nixArgs} \
    "$@"
  '';
}
