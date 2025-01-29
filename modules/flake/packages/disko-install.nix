outer @ {
  self,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = "disko-install";
    text = let
      args = let
        inherit (outer) specialArgs;
      in
        specialArgs.nixArgs;
    in ''
      disko() {
        mode="$1"
        shift

        ${lib.meta.getExe' pkgs.disko "disko-install"} \
          ${lib.strings.concatStringsSep " " args} \
          --flake "${self}#{{ hostname }}" \
          --mode "$mode" \
        "$@"
      }

      disko format \
        --write-efi-boot-entries \
        "$@"
    '';
  }
