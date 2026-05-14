{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.menuBar = {
      autohide = lib.options.mkEnableOption "menu bar autohide";
    };
  };
}
