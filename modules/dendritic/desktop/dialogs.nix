{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.dialogs = {
      expandSavePanel = lib.options.mkEnableOption "expanded save panels" // {default = true;};
      expandPrintPanel = lib.options.mkEnableOption "expanded print panels" // {default = true;};
    };
  };
}
