{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.remoteDesktop.rdp = {
      enable = lib.options.mkEnableOption "RDP remote desktop" // {default = true;};
      viewOnly = lib.options.mkEnableOption "view-only RDP sessions";
    };
  };
}
