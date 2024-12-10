{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) modules;
in {
  disabledModules = [../darwin];

  specialisation = {
    default = modules.mkIf pkgs.stdenv.isLinux {
      configuration = import ./generic-linux.nix;
    };

    generic-linux = modules.mkIf pkgs.stdenv.isLinux {
      configuration = import ./generic-linux.nix;
    };

    fortress = modules.mkIf pkgs.stdenv.isLinux {
      configuration = import ./fortress.nix;
    };
  };
}
