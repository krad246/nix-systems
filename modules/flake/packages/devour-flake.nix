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
    args = lib.cli.toGNUCommandLine {} {
      option = [
        "inputs-from ${self}"
        "experimental-features 'nix-command flakes'"
        "keep-going true"
        "show-trace true"
        "accept-flake-config true"
        "builders-use-substitutes true"
        "preallocate-contents true"
      ];
    };
  in ''
    set -x
    ${bin} "${self}" \
      ${lib.strings.concatStringsSep " " args} \
    "$@"
  '';
}
