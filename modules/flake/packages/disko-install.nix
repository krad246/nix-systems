{
  self,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
in
  pkgs.writeShellApplication {
    name = "disko-install";
    text = let
      args = lib.cli.toGNUCommandLine {} {
        option = ["inputs-from ${self}" "experimental-features 'nix-command flakes'"];
      };
    in ''
      disko() {
        mode="$1"
        shift

        ${lib.meta.getExe' pkgs.disko "disko-install"} \
          ${lib.strings.concatStringsSep " " args} \
          --flake "${self}#$HOSTNAME" \
          --mode "$mode" \
        "$@"
      }

      disko format \
        --write-efi-boot-entries \
        "$@"
    '';
  }
