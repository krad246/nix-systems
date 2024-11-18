{pkgs, ...}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = "disko-install";
    text = ''
      disko() {
        mode="$1"
        shift

        ${lib.getExe' pkgs.disko "disko-install"} \
          --flake "$FLAKE_ROOT#$HOSTNAME" \
          --option inputs-from "$FLAKE_ROOT" \
          --option experimental-features 'nix-command flakes' \
          --mode "$mode" \
        "$@"
      }

      disko format \
        --write-efi-boot-entries \
        "$@"
    '';
  }
