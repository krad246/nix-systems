{
  self,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = "disko-install";
    text = ''
      disko() {
        mode="$1"
        shift

        ${lib.meta.getExe' pkgs.disko "disko-install"} \
          --flake "${self}#$HOSTNAME" \
          --option inputs-from "${self}" \
          --option experimental-features 'nix-command flakes' \
          --mode "$mode" \
        "$@"
      }

      disko format \
        --write-efi-boot-entries \
        "$@"
    '';
  }
