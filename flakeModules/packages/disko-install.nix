{
  self,
  lib,
  writeShellApplication,
  disko,
  ...
}: let
  inherit (lib) meta;
in
  writeShellApplication {
    name = "disko-install";
    text = ''
      disko() {
        mode="$1"
        shift

        ${meta.getExe' disko "disko-install"} \
          --flake "${self}#{{ hostname }}" \
          --mode "$mode" \
        "$@"
      }

      disko format \
        --write-efi-boot-entries \
        "$@"
    '';
  }
