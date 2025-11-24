{
  lib,
  pkgs,
  ...
}: let
  # inherit (pkgs) lib;
  inherit (lib) modules;
in {
  programs.bottom = {
    enable = true;
    settings = {
    };
  };

  xdg = modules.mkIf pkgs.stdenv.isLinux {
    enable = true;
    desktopEntries = {
      "bottom" = {
        name = "bottom";
        noDisplay = true;
      };
    };
  };
}
