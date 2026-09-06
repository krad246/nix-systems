{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.theme.nightLight = {
      enable = lib.options.mkEnableOption "night light" // {default = true;};

      automaticSchedule = lib.options.mkEnableOption "automatic night-light scheduling";
    };
  };
}
