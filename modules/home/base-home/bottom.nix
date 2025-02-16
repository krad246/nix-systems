{
  lib,
  pkgs,
  ...
}: {
  programs.bottom = {
    enable = true;
    settings = {
    };
  };

  xdg = lib.modules.mkIf pkgs.stdenv.isLinux {
    enable = true;
    desktopEntries = {
      "bottom" = {
        name = "bottom";
        noDisplay = true;
      };
    };
  };
}
