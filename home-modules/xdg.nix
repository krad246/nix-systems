{pkgs, ...}: let
  mkHidden = args @ {name, ...}:
    pkgs.makeDesktopItem (args
      // {
        desktopName = name;
        noDisplay = true;
      });
in {
  home.packages = [
    (mkHidden {name = "KDE Connect Indicator";})
    (mkHidden {name = "KDE Connect Settings";})
  ];
}
