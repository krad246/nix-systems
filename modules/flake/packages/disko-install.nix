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
        flake = "${self}#$HOSTNAME";
        mode = "$mode";
        option = ["inputs-from ${self}" "experimental-features 'nix-command flakes'"];
      };
    in ''
      disko() {
        mode="$1"
        shift

        ${lib.meta.getExe' pkgs.disko "disko-install"} \
          ${lib.strings.concatStringsSep " " args} \
          --option inputs-from "${self}" \
          --option experimental-features 'nix-command flakes' \
        "$@"
      }

      disko format \
        --write-efi-boot-entries \
        "$@"
    '';
  }
