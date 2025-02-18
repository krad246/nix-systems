{
  self,
  lib,
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "disko-install";
  text = ''
    disko() {
      mode="$1"
      shift

      ${lib.meta.getExe' pkgs.disko "disko-install"} \
        --flake "${self}#{{ hostname }}" \
        --mode "$mode" \
      "$@"
    }

    disko format \
      --write-efi-boot-entries \
      "$@"
  '';
}
