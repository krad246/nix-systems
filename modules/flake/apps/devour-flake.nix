{
  self,
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
  runner = pkgs.writeShellApplication {
    name = "devour-flake";

    # FIXME: devour-flake does not work with recursive flake inputs', must handle; breaks devour-flake
    text = ''
      set -x
      ${lib.getExe pkgs.nixVersions.stable} \
        --option experimental-features 'nix-command flakes' \
        flake lock --no-update-lock-file "${self}" && \
      ${lib.getExe (pkgs.callPackage inputs.devour-flake {})} "${self}" \
        --option preallocate-contents true \
        --option inputs-from ${self} \
        --option keep-going true \
        --option show-trace true \
      "$@"
    '';
  };
in {
  type = "app";
  program = lib.getExe runner;
  meta.description = "Build all flake outputs in parallel.";
}