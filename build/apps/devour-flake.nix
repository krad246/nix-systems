{
  self,
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
  runner = pkgs.writeShellApplication {
    name = "devour-flake";
    text = ''
      set -x
      ${lib.getExe pkgs.nixFlakes} \
        --option experimental-features 'nix-command flakes' \
        flake lock --no-update-lock-file "${self}" && \
      ${lib.getExe (pkgs.callPackage inputs.devour-flake {})} "${self}" "$@"
    '';
  };
in {
  type = "app";
  program = lib.getExe runner;
  meta.description = "Build all flake outputs in parallel.";
}
