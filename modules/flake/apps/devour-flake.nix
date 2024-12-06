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
      ${lib.meta.getExe (pkgs.callPackage inputs.devour-flake {})} "${self}" \
        --option preallocate-contents true \
        --option inputs-from "${self}" \
        --option keep-going true \
        --option show-trace true \
      "$@"
    '';
  };
in {
  type = "app";
  program = lib.meta.getExe runner;
  meta.description = "Build all flake outputs in parallel.";
}
