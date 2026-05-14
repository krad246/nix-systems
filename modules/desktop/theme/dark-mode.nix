{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.theme.darkMode = {
      enable = lib.options.mkEnableOption "dark desktop appearance" // {default = true;};

      automatic = lib.options.mkEnableOption "automatic light/dark switching";
    };
  };
}
